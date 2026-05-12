import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_imagehash/dart_imagehash.dart';
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
      ..sort((AssetEntity a, AssetEntity b) => a.createDateTime.compareTo(b.createDateTime));

    final List<CleanupSuggestion> suggestions = <CleanupSuggestion>[];

    for (final List<AssetEntity> group in _timeGroups(imageAssets)) {
      if (group.length < 2) continue;
      suggestions.addAll(await _analyzeGroup(group));
    }

    return suggestions;
  }

  Future<List<CleanupSuggestion>> _analyzeGroup(
      List<AssetEntity> assets,
      ) async {
    final List<_DuplicateCandidate> candidates = <_DuplicateCandidate>[];

    for (final AssetEntity asset in assets) {
      try {
        final ImageHash? hash = await _imageHash(asset);
        if (hash != null) {
          candidates.add(_DuplicateCandidate(asset: asset, hash: hash));
        }
      } catch (_) {
        continue;
      }
    }

    if (candidates.length < 2) return <CleanupSuggestion>[];

    final Map<String, CleanupSuggestion> suggestions = <String, CleanupSuggestion>{};
    final List<_DuplicateCandidate> representatives = <_DuplicateCandidate>[];

    for (final _DuplicateCandidate candidate in candidates) {
      _DuplicateCandidate? matched;
      int? matchedDistance;

      for (final _DuplicateCandidate representative in representatives) {
        final int distance = candidate.hash - representative.hash;

        if (distance <= maxHammingDistance) {
          matched = representative;
          matchedDistance = distance;
          break;
        }
      }

      if (matched == null) {
        representatives.add(candidate);
        continue;
      }

      final _DuplicateCandidate duplicate = _worseCandidate(candidate, matched);
      final _DuplicateCandidate original =
      duplicate.asset.id == candidate.asset.id ? matched : candidate;

      suggestions[duplicate.asset.id] = _suggestion(
        duplicate: duplicate,
        original: original,
        distance: matchedDistance ?? (candidate.hash - matched.hash),
      );

      if (duplicate.asset.id == matched.asset.id) {
        representatives.remove(matched);
        representatives.add(candidate);
      }
    }

    return suggestions.values.toList();
  }

  Future<ImageHash?> _imageHash(AssetEntity asset) async {
    final Uint8List? bytes = await asset.thumbnailDataWithSize(
      thumbnailSize,
      quality: thumbnailQuality,
    );

    if (bytes == null || bytes.isEmpty) return null;

    return ImageHasher.perceptualHashFromBytes(bytes);
  }

  Iterable<List<AssetEntity>> _timeGroups(List<AssetEntity> assets) sync* {
    if (assets.isEmpty) return;

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

    if (current.isNotEmpty) yield current;
  }

  CleanupSuggestion _suggestion({
    required _DuplicateCandidate duplicate,
    required _DuplicateCandidate original,
    required int distance,
  }) {
    final double similarity = (1 - (distance / math.max(maxHammingDistance, 1)))
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
        'original_created_at': original.asset.createDateTime.toIso8601String(),
        'duplicate_created_at':
        duplicate.asset.createDateTime.toIso8601String(),
      },
    );
  }

  _DuplicateCandidate _worseCandidate(
      _DuplicateCandidate first,
      _DuplicateCandidate second,
      ) {
    final int firstPixels = first.asset.orientatedWidth * first.asset.orientatedHeight;
    final int secondPixels =
        second.asset.orientatedWidth * second.asset.orientatedHeight;

    if (firstPixels == secondPixels) {
      return first.asset.createDateTime.isAfter(second.asset.createDateTime)
          ? first
          : second;
    }

    return firstPixels < secondPixels ? first : second;
  }
}

class _DuplicateCandidate {
  const _DuplicateCandidate({
    required this.asset,
    required this.hash,
  });

  final AssetEntity asset;
  final ImageHash hash;
}