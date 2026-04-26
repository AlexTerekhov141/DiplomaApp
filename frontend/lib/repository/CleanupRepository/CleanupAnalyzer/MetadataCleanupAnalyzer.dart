import 'package:photo_manager/photo_manager.dart';

import '../../../models/CleanUp/CleanupSeggestionStatus.dart';
import '../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../models/CleanUp/CleanupSuggestionType.dart';

class MetadataCleanupAnalyzer {
  MetadataCleanupAnalyzer({
    DateTime? now,
    this.staleScreenshotAge = const Duration(days: 90),
    this.staleDocumentAge = const Duration(days: 180),
    this.minUsefulWidth = 300,
    this.minUsefulHeight = 300,
  }) : _now = now ?? DateTime.now();

  final DateTime _now;
  final Duration staleScreenshotAge;
  final Duration staleDocumentAge;
  final int minUsefulWidth;
  final int minUsefulHeight;

  Future<CleanupSuggestion?> analyze(AssetEntity asset) async {
    if (asset.type != AssetType.image) {
      return null;
    }

    final String title = await _safeTitle(asset);
    final String relativePath = asset.relativePath ?? '';
    final DateTime createdAt = _safeDate(asset.createDateTime);
    final DateTime updatedAt = _safeDate(asset.modifiedDateTime);

    final _MetadataSignals signals = _MetadataSignals(
      asset: asset,
      title: title,
      relativePath: relativePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      age: _now.difference(createdAt),
    );

    if (_isScreenshot(signals)) {
      return _suggestion(
        asset: asset,
        type: CleanupSuggestionType.screenshot,
        score: _screenshotScore(signals),
        reason: signals.age >= staleScreenshotAge ? 'Old' : 'screenshot',
        features: signals.toFeatures()
          ..addAll(<String, dynamic>{
            'is_screenshot': true,
            'stale_screenshot_days': staleScreenshotAge.inDays,
          }),
      );
    }

    if (_isDocumentLike(signals)) {
      return _suggestion(
        asset: asset,
        type: CleanupSuggestionType.document,
        score: _documentScore(signals),
        reason: signals.age >= staleDocumentAge ? 'Oldphoto' : 'document',
        features: signals.toFeatures()
          ..addAll(<String, dynamic>{
            'is_document_like': true,
            'stale_document_days': staleDocumentAge.inDays,
          }),
      );
    }

    if (_isLowResolution(signals)) {
      return _suggestion(
        asset: asset,
        type: CleanupSuggestionType.badQuality,
        score: 0.58,
        reason: 'low',
        features: signals.toFeatures()
          ..addAll(<String, dynamic>{
            'is_low_resolution': true,
            'min_useful_width': minUsefulWidth,
            'min_useful_height': minUsefulHeight,
          }),
      );
    }

    return null;
  }

  Future<List<CleanupSuggestion>> analyzeAll(
    Iterable<AssetEntity> assets,
  ) async {
    final List<CleanupSuggestion> suggestions = <CleanupSuggestion>[];

    for (final AssetEntity asset in assets) {
      final CleanupSuggestion? suggestion = await analyze(asset);
      if (suggestion != null) {
        suggestions.add(suggestion);
      }
    }

    return suggestions;
  }

  CleanupSuggestion _suggestion({
    required AssetEntity asset,
    required CleanupSuggestionType type,
    required double score,
    required String reason,
    required Map<String, dynamic> features,
  }) {
    final DateTime now = DateTime.now();
    return CleanupSuggestion(
      assetId: asset.id,
      type: type,
      status: CleanupSuggestionStatus.suggested,
      score: score.clamp(0.0, 1.0),
      reason: reason,
      createdAt: now,
      updatedAt: now,
      features: features,
    );
  }

  bool _isScreenshot(_MetadataSignals signals) {
    final String text = signals.searchText;
    if (_containsAny(text, _screenshotMarkers)) {
      return true;
    }

    final bool hasScreenAspect = signals.aspectRatio >= 1.7 || signals.inverseAspectRatio >= 1.7;
    final bool hasNoLocation = signals.asset.latitude == null && signals.asset.longitude == null;

    return hasScreenAspect && hasNoLocation && signals.age >= staleScreenshotAge;
  }

  double _screenshotScore(_MetadataSignals signals) {
    double score = 0.45;
    final String text = signals.searchText;

    if (_containsAny(text, _screenshotMarkers)) {
      score += 0.35;
    }
    if (signals.age >= staleScreenshotAge) {
      score += 0.15;
    }
    if (signals.asset.latitude == null && signals.asset.longitude == null) {
      score += 0.05;
    }

    return score;
  }

  bool _isDocumentLike(_MetadataSignals signals) {
    return _containsAny(signals.searchText, _documentMarkers);
  }

  double _documentScore(_MetadataSignals signals) {
    double score = 0.52;
    if (signals.age >= staleDocumentAge) {
      score += 0.18;
    }
    if (_containsAny(signals.searchText, _strongDocumentMarkers)) {
      score += 0.12;
    }
    return score;
  }

  bool _isLowResolution(_MetadataSignals signals) {
    return signals.asset.orientatedWidth > 0 && signals.asset.orientatedHeight > 0 && (signals.asset.orientatedWidth < minUsefulWidth || signals.asset.orientatedHeight < minUsefulHeight);
  }

  Future<String> _safeTitle(AssetEntity asset) async {
    final String? cachedTitle = asset.title;
    if (cachedTitle != null && cachedTitle.trim().isNotEmpty) {
      return cachedTitle;
    }

    try {
      return asset.titleAsync;
    } catch (_) {
      return '';
    }
  }

  DateTime _safeDate(DateTime date) {
    if (date.year <= 1971) {
      return _now;
    }
    return date;
  }

  bool _containsAny(String value, List<String> markers) {
    return markers.any(value.contains);
  }

  static const List<String> _screenshotMarkers = <String>['screenshot',];

  static const List<String> _documentMarkers = <String>['document',];

  static const List<String> _strongDocumentMarkers = <String>['scan',];
}

class _MetadataSignals {
  const _MetadataSignals({
    required this.asset,
    required this.title,
    required this.relativePath,
    required this.createdAt,
    required this.updatedAt,
    required this.age,
  });

  final AssetEntity asset;
  final String title;
  final String relativePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Duration age;

  String get searchText => '$title $relativePath'.toLowerCase();

  double get aspectRatio {
    final int width = asset.orientatedWidth;
    final int height = asset.orientatedHeight;
    if (width <= 0 || height <= 0) {
      return 1.0;
    }
    return width / height;
  }

  double get inverseAspectRatio {
    final double ratio = aspectRatio;
    if (ratio == 0) {
      return 1.0;
    }
    return 1 / ratio;
  }

  Map<String, dynamic> toFeatures() {
    return <String, dynamic>{
      'title': title,
      'relative_path': relativePath,
      'width': asset.orientatedWidth,
      'height': asset.orientatedHeight,
      'asset_type': asset.type.name,
      'created_at': createdAt.toIso8601String(),
      'modified_at': updatedAt.toIso8601String(),
      'age_days': age.inDays,
      'has_location': asset.latitude != null && asset.longitude != null,
      'aspect_ratio': aspectRatio,
    };
  }
}
