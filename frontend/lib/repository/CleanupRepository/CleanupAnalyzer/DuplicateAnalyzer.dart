import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

import '../../../models/CleanUp/CleanupSeggestionStatus.dart';
import '../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../models/CleanUp/CleanupSuggestionType.dart';

class DuplicateAnalyzer {
  DuplicateAnalyzer({
    DateTime? now,
    this.timeWindow = const Duration(seconds: 20),
    this.maxHammingDistance = 8,
    this.thumbnailSize = const ThumbnailSize(96, 96),
    this.thumbnailQuality = 70,
  }) : _now = now ?? DateTime.now();

  final DateTime _now;
  final Duration timeWindow;
  final int maxHammingDistance;
  final ThumbnailSize thumbnailSize;
  final int thumbnailQuality;

  Future<List<CleanupSuggestion>> analyzeAll(
    Iterable<AssetEntity> assets,
  ) async {
    final List<AssetEntity> imageAssets = assets
        .where((AssetEntity asset) => asset.type == AssetType.image)
        .toList()
      ..sort(
        (AssetEntity a, AssetEntity b) =>
            a.createDateTime.compareTo(b.createDateTime),
      );

    final List<CleanupSuggestion> suggestions = <CleanupSuggestion>[];

    for (final List<AssetEntity> group in _timeGroups(imageAssets)) {
      if (group.length < 2) {
        continue;
      }

      suggestions.addAll(await _analyzeGroup(group));
    }

    return suggestions;
  }

  Future<List<CleanupSuggestion>> _analyzeGroup(
    List<AssetEntity> assets,
  ) async {
    final List<_DuplicateCandidate> candidates = <_DuplicateCandidate>[];

    for (final AssetEntity asset in assets) {
      final int? hash = await _differenceHash(asset);
      if (hash == null) {
        continue;
      }
      candidates.add(_DuplicateCandidate(asset: asset, hash: hash));
    }

    if (candidates.length < 2) {
      return <CleanupSuggestion>[];
    }

    final Map<String, CleanupSuggestion> suggestions =
        <String, CleanupSuggestion>{};
    final List<_DuplicateCandidate> representatives = <_DuplicateCandidate>[];

    for (final _DuplicateCandidate candidate in candidates) {
      _DuplicateCandidate? matched;

      for (final _DuplicateCandidate representative in representatives) {
        final int distance = _hammingDistance(
          candidate.hash,
          representative.hash,
        );
        if (distance <= maxHammingDistance) {
          matched = representative;
          break;
        }
      }

      if (matched == null) {
        representatives.add(candidate);
        continue;
      }

      final _DuplicateCandidate duplicate = _worseCandidate(
        candidate,
        matched,
      );
      final _DuplicateCandidate original =
          duplicate.asset.id == candidate.asset.id ? matched : candidate;

      suggestions[duplicate.asset.id] = _suggestion(
        duplicate: duplicate,
        original: original,
        distance: _hammingDistance(candidate.hash, matched.hash),
      );

      if (duplicate.asset.id == matched.asset.id) {
        representatives.remove(matched);
        representatives.add(candidate);
      }
    }

    return suggestions.values.toList();
  }

  Iterable<List<AssetEntity>> _timeGroups(List<AssetEntity> assets) sync* {
    if (assets.isEmpty) {
      return;
    }

    final List<AssetEntity> current = <AssetEntity>[];

    for (final AssetEntity asset in assets) {
      if (current.isEmpty) {
        current.add(asset);
        continue;
      }

      final DateTime firstCreatedAt = current.first.createDateTime;
      final Duration distance = asset.createDateTime.difference(firstCreatedAt);

      if (distance.inMilliseconds <= timeWindow.inMilliseconds) {
        current.add(asset);
      } else {
        yield List<AssetEntity>.from(current);
        current
          ..clear()
          ..add(asset);
      }
    }

    if (current.isNotEmpty) {
      yield current;
    }
  }

  Future<int?> _differenceHash(AssetEntity asset) async {
    final Uint8List? bytes = await asset.thumbnailDataWithSize(
      thumbnailSize,
      quality: thumbnailQuality,
    );
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }

    final img.Image resized = img.copyResize(
      decoded,
      width: 9,
      height: 8,
      interpolation: img.Interpolation.average,
    );

    int hash = 0;
    int bit = 0;

    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final double left = _luminance(resized.getPixel(x, y));
        final double right = _luminance(resized.getPixel(x + 1, y));
        if (left > right) {
          hash |= 1 << bit;
        }
        bit++;
      }
    }

    return hash;
  }

  CleanupSuggestion _suggestion({
    required _DuplicateCandidate duplicate,
    required _DuplicateCandidate original,
    required int distance,
  }) {
    final double similarity =
        (1 - (distance / math.max(maxHammingDistance, 1)))
            .clamp(0.0, 1.0)
            .toDouble();
    final double score = 0.62 + similarity * 0.3;

    return CleanupSuggestion(
      assetId: duplicate.asset.id,
      type: CleanupSuggestionType.duplicate,
      status: CleanupSuggestionStatus.suggested,
      score: score.clamp(0.0, 0.95).toDouble(),
      reason: 'Image looks similar to another photo',
      createdAt: _now,
      updatedAt: _now,
      groupId: 'duplicate_${original.asset.id}',
      features: <String, dynamic>{
        'original_asset_id': original.asset.id,
        'duplicate_asset_id': duplicate.asset.id,
        'hamming_distance': distance,
        'max_hamming_distance': maxHammingDistance,
        'time_window_seconds': timeWindow.inSeconds,
        'original_created_at':
            original.asset.createDateTime.toIso8601String(),
        'duplicate_created_at':
            duplicate.asset.createDateTime.toIso8601String(),
      },
    );
  }

  _DuplicateCandidate _worseCandidate(
    _DuplicateCandidate first,
    _DuplicateCandidate second,
  ) {
    final int firstPixels = first.asset.orientatedWidth *
        first.asset.orientatedHeight;
    final int secondPixels = second.asset.orientatedWidth *
        second.asset.orientatedHeight;

    if (firstPixels == secondPixels) {
      return first.asset.createDateTime.isAfter(second.asset.createDateTime)
          ? first
          : second;
    }

    return firstPixels < secondPixels ? first : second;
  }

  int _hammingDistance(int first, int second) {
    int value = first ^ second;
    int distance = 0;

    while (value != 0) {
      distance += value & 1;
      value >>= 1;
    }

    return distance;
  }

  double _luminance(img.Pixel pixel) {
    final double r = pixel.r.toDouble() / 255.0;
    final double g = pixel.g.toDouble() / 255.0;
    final double b = pixel.b.toDouble() / 255.0;
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }
}

class _DuplicateCandidate {
  const _DuplicateCandidate({
    required this.asset,
    required this.hash,
  });

  final AssetEntity asset;
  final int hash;
}
