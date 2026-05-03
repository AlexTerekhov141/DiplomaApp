import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:categorize_app/repository/PhotosRepository/PhotosRepository.dart';
import 'package:categorize_app/repository/TFliteRepository/TFliteRepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../constants/Keys.dart';
import '../OfflinePredictionsStorage/OfflinePredictionsStorage.dart';

class Offlinephotosrepositoryimpl implements PhotosRepository {
  Offlinephotosrepositoryimpl({
    required this.storage,
    required this.tflite,
    required this.predictionsStorage,
  });

  final FlutterSecureStorage storage;
  final TFliteRepository tflite;
  final OfflinePredictionsStorage predictionsStorage;
  static const int _defaultBatchSize = 20;
  static const int _assetPageSize = 100;
  static const ThumbnailSize _classificationThumbnailSize = ThumbnailSize(
    224,
    224,
  );
  int _nextProcessingPage = 0;
  bool _legacyMigrationChecked = false;

  @override
  Future<int> bulkUploadLocalPhotos(List<AssetEntity> assets) async {
    if (assets.isEmpty) {
      return 0;
    }

    await tflite.ensureInitialized();
    await _migrateLegacyPredictionsIfNeeded();
    final Map<String, Map<String, dynamic>> predictions =
        await predictionsStorage.getPredictionsByIds(
      assets.map((AssetEntity asset) => asset.id),
    );
    final Map<String, Map<String, dynamic>> batchPredictions =
        <String, Map<String, dynamic>>{};
    int processed = 0;

    for (final AssetEntity asset in assets) {
      final Map<String, dynamic>? cached = predictions[asset.id];
      if (!_needsReclassification(cached)) {
        continue;
      }
      final Uint8List? bytes = await _loadClassificationBytes(asset);
      if (bytes == null) {
        continue;
      }
      try {
        final TFlitePrediction prediction = await tflite.classifyImageBytes(
          bytes,
        );
        batchPredictions[asset.id] = _predictionToMap(prediction);
        processed++;
      } catch (_) {
        batchPredictions[asset.id] = _fallbackProcessedPrediction();
        processed++;
      }
    }

    if (processed > 0) {
      await predictionsStorage.upsertPredictions(batchPredictions);
    }

    return processed;
  }

  @override
  Future<int> processNextBatch({
    int batchSize = _defaultBatchSize,
  }) async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      return 0;
    }

    await tflite.ensureInitialized();

    final AssetPathEntity? recentAlbum = await _getRecentAlbum();
    if (recentAlbum == null) {
      return 0;
    }

    final int totalAssets = await recentAlbum.assetCountAsync;
    if (totalAssets <= 0) {
      return 0;
    }

    await _migrateLegacyPredictionsIfNeeded();

    final int totalPages = (totalAssets / _assetPageSize).ceil();
    if (_nextProcessingPage >= totalPages) {
      _nextProcessingPage = 0;
    }

    final Map<String, Map<String, dynamic>> batchPredictions =
        <String, Map<String, dynamic>>{};

    int processed = 0;
    int checkedPages = 0;
    int page = _nextProcessingPage;

    while (checkedPages < totalPages && processed < batchSize) {
      final List<AssetEntity> pageItems = await recentAlbum.getAssetListPaged(
        page: page,
        size: _assetPageSize,
      );
      final Map<String, Map<String, dynamic>> pagePredictions =
          await predictionsStorage.getPredictionsByIds(
        pageItems.map((AssetEntity asset) => asset.id),
      );

      for (final AssetEntity asset in pageItems) {
        if (processed >= batchSize) {
          break;
        }

        final Map<String, dynamic>? cached = pagePredictions[asset.id];
        if (!_needsReclassification(cached)) {
          continue;
        }

        final Uint8List? bytes = await _loadClassificationBytes(asset);
        if (bytes == null) {
          batchPredictions[asset.id] = _fallbackProcessedPrediction();
          processed++;
          continue;
        }

        try {
          final TFlitePrediction prediction = await tflite.classifyImageBytes(
            bytes,
          );
          batchPredictions[asset.id] = _predictionToMap(prediction);
          processed++;
        } catch (_) {
          batchPredictions[asset.id] = _fallbackProcessedPrediction();
          processed++;
        }
      }

      checkedPages++;
      page = (page + 1) % totalPages;
    }

    _nextProcessingPage = page;
    await predictionsStorage.upsertPredictions(batchPredictions);
    return processed;
  }

  @override
  Future<List<Map<String, dynamic>>> getBestPhotos() async {
    final List<Map<String, dynamic>> photos = await getPhotos(
      isProcessed: true,
    );
    photos.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final double aScore = (a['quality_score'] as num?)?.toDouble() ?? 0.0;
      final double bScore = (b['quality_score'] as num?)?.toDouble() ?? 0.0;
      return bScore.compareTo(aScore);
    });
    return photos;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final List<Map<String, dynamic>> photos = await getPhotos(
      isProcessed: true,
    );

    final Map<String, Map<String, dynamic>> grouped =
        <String, Map<String, dynamic>>{};
    for (final Map<String, dynamic> photo in photos) {
      final Map<String, dynamic>? category =
          photo['category'] as Map<String, dynamic>?;
      if (category == null) {
        continue;
      }
      final String id = (category['id'] ?? '').toString();
      final String name = (category['name'] ?? '').toString();
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      final Map<String, dynamic> current = grouped[id] ??
          <String, dynamic>{
            'id': id,
            'name': name,
            'photos_count': 0,
          };
      current['photos_count'] = (current['photos_count'] as int) + 1;
      grouped[id] = current;
    }

    return grouped.values.toList()
      ..sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final String aName = (a['name'] ?? '').toString();
        final String bName = (b['name'] ?? '').toString();
        return aName.compareTo(bName);
      });
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    return _readStringSet(favoritePhotoIdsKey);
  }

  @override
  Future<List<Map<String, dynamic>>> getPhotos({
    String? tag,
    bool? isProcessed,
    bool forceRefresh = false,
  }) async {
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      return <Map<String, dynamic>>[];
    }

    await _migrateLegacyPredictionsIfNeeded();

    final List<AssetEntity> assets = await _loadAllAssets();
    final Set<String> existingAssetIds =
        assets.map((AssetEntity a) => a.id).toSet();
    final Map<String, Map<String, dynamic>> predictions =
        await predictionsStorage.getPredictionsByIds(existingAssetIds);
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    await predictionsStorage.deleteMissingAssets(existingAssetIds);

    for (final AssetEntity asset in assets) {
      final Map<String, dynamic>? prediction = predictions[asset.id];
      final Map<String, dynamic> safePrediction = _needsReclassification(
        prediction,
      )
          ? _unprocessedPrediction()
          : prediction ?? _unprocessedPrediction();
      final Map<String, dynamic> photo = _toPhotoMap(asset, safePrediction);
      if (_matchesFilters(photo, tag: tag, isProcessed: isProcessed)) {
        result.add(photo);
      }
    }

    return result;
  }

  @override
  Future<Map<String, int>> getRemoteProcessingStats() async {
    await _migrateLegacyPredictionsIfNeeded();

    final AssetPathEntity? recentAlbum = await _getRecentAlbum();
    if (recentAlbum == null) {
      return <String, int>{
        'total': 0,
        'processed': 0,
        'pending': 0,
      };
    }

    final int total = await recentAlbum.assetCountAsync;
    final int rawProcessed = await predictionsStorage.countProcessed(
      currentModelVersion,
    );
    final int processed = rawProcessed > total ? total : rawProcessed;
    final int pending = total - processed > 0 ? total - processed : 0;

    return <String, int>{
      'total': total,
      'processed': processed,
      'pending': pending,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    final List<Map<String, dynamic>> photos = await getPhotos(isProcessed: true);
    final Map<String, int> tagsCount = <String, int>{};

    for (final Map<String, dynamic> photo in photos) {
      final List<dynamic> rawTags = photo['tags'] as List<dynamic>? ?? <dynamic>[];
      for (final dynamic rawTag in rawTags) {
        if (rawTag is! Map<String, dynamic>) {
          continue;
        }
        final String tagName = (rawTag['name'] ?? '').toString().trim();
        if (tagName.isEmpty) {
          continue;
        }
        tagsCount[tagName] = (tagsCount[tagName] ?? 0) + 1;
      }
    }

    int index = 0;
    return tagsCount.entries.map((MapEntry<String, int> entry) {
      index++;
      return <String, dynamic>{
        'id': index.toString(),
        'name': entry.key,
        'photos_count': entry.value,
      };
    }).toList();
  }

  Future<Set<String>> _readStringSet(String key) async {
    final String? raw = await storage.read(key: key);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<String>().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  @override
  Future<Set<String>> getTrashedIds() async {
    return _readStringSet(trashedPhotoIdsKey);
  }

  @override
  Future<bool> isFavorite(String assetId) async {
    final Set<String> currentIds = await getFavoriteIds();
    return currentIds.contains(assetId);
  }

  @override
  Future<bool> isTrashed(String assetId) async {
    final Set<String> currentIds = await getTrashedIds();
    return currentIds.contains(assetId);
  }

  Future<void> _writeFavoriteIds(Set<String> ids) async {
    await _writeStringSet(favoritePhotoIdsKey, ids);
  }

  @override
  Future<void> toggleFavorite(String assetId) async {
    final Set<String> currentIds = await getFavoriteIds();
    if (currentIds.contains(assetId)) {
      currentIds.remove(assetId);
    } else {
      currentIds.add(assetId);
    }
    await _writeFavoriteIds(currentIds);
  }

  Future<void> _writeStringSet(String key, Set<String> ids) async {
    await storage.write(key: key, value: jsonEncode(ids.toList()));
  }

  Future<void> _writeTrashedIds(Set<String> ids) async {
    await _writeStringSet(trashedPhotoIdsKey, ids);
  }

  @override
  Future<void> toggleTrash(String assetId) async {
    final Set<String> currentIds = await getTrashedIds();
    if (currentIds.contains(assetId)) {
      currentIds.remove(assetId);
    } else {
      currentIds.add(assetId);
    }
    await _writeTrashedIds(currentIds);
  }

  Future<AssetPathEntity?> _getRecentAlbum() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        orders: const <OrderOption>[
          OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) {
      return null;
    }
    return albums.first;
  }

  Future<List<AssetEntity>> _loadAllAssets() async {
    final AssetPathEntity? recentAlbum = await _getRecentAlbum();
    if (recentAlbum == null) {
      return <AssetEntity>[];
    }

    int page = 0;
    final List<AssetEntity> all = <AssetEntity>[];

    while (true) {
      final List<AssetEntity> pageItems = await recentAlbum.getAssetListPaged(
        page: page,
        size: _assetPageSize,
      );
      if (pageItems.isEmpty) {
        break;
      }
      all.addAll(pageItems);
      page++;
    }

    return all;
  }

  Future<Uint8List?> _loadClassificationBytes(AssetEntity asset) async {
    final Uint8List? thumbnailBytes = await asset.thumbnailDataWithSize(
      _classificationThumbnailSize,
      quality: 85,
    );
    if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
      return thumbnailBytes;
    }

    final File? file = await asset.file;
    if (file == null || !file.existsSync()) {
      return null;
    }
    return file.readAsBytes();
  }

  Future<void> _migrateLegacyPredictionsIfNeeded() async {
    if (_legacyMigrationChecked) {
      return;
    }

    final String? migrated = await storage.read(key: legacyMigrationKey);
    if (migrated == 'true') {
      _legacyMigrationChecked = true;
      return;
    }

    final Map<String, Map<String, dynamic>> legacyPredictions =
        await _readLegacyPredictionsMap();
    if (legacyPredictions.isNotEmpty) {
      await predictionsStorage.upsertPredictions(legacyPredictions);
    }

    await storage.write(key: legacyMigrationKey, value: 'true');
    await storage.delete(key: offlinePredictionsKey);
    _legacyMigrationChecked = true;
  }

  Future<Map<String, Map<String, dynamic>>> _readLegacyPredictionsMap() async {
    final String? raw =
        await storage.read(key: offlinePredictionsKey);
    if (raw == null || raw.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, Map<String, dynamic>> result =
          <String, Map<String, dynamic>>{};
      decoded.forEach((String key, dynamic value) {
        if (value is Map<String, dynamic>) {
          result[key] = value;
        }
      });
      return result;
    } catch (_) {
      return <String, Map<String, dynamic>>{};
    }
  }

  Map<String, dynamic> _predictionToMap(TFlitePrediction prediction) {
    return <String, dynamic>{
      'label': prediction.label,
      'confidence': prediction.confidence,
      'processed': true,
      'tags': <String>[prediction.label],
      'model_version': currentModelVersion,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _unprocessedPrediction() {
    return <String, dynamic>{
      'label': 'uncategorized',
      'confidence': 0.0,
      'processed': false,
      'tags': <String>['uncategorized'],
      'model_version': currentModelVersion,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _fallbackProcessedPrediction() {
    return <String, dynamic>{
      'label': 'uncategorized',
      'confidence': 0.0,
      'processed': true,
      'tags': <String>['uncategorized'],
      'model_version': currentModelVersion,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  bool _needsReclassification(Map<String, dynamic>? prediction) {
    if (prediction == null) {
      return true;
    }
    final bool processed = (prediction['processed'] as bool?) ?? false;
    final String version = (prediction['model_version'] ?? '').toString();
    if (!processed) {
      return true;
    }
    if (version != currentModelVersion) {
      return true;
    }

    return false;
  }

  Map<String, dynamic> _toPhotoMap(
    AssetEntity asset,
    Map<String, dynamic> prediction,
  ) {
    final String label = (prediction['label'] ?? 'uncategorized').toString();
    final String categoryId = label.isEmpty ? 'uncategorized' : label;
    final String categoryName = label.isEmpty ? 'Uncategorized' : label;
    final double confidence =
        (prediction['confidence'] as num?)?.toDouble() ?? 0.0;
    final List<dynamic> rawTags = prediction['tags'] as List<dynamic>? ??
        <dynamic>[categoryName];
    final List<Map<String, dynamic>> tags = rawTags
        .map((dynamic e) => <String, dynamic>{'name': e.toString()})
        .toList();

    return <String, dynamic>{
      'id': asset.id.hashCode & 0x7fffffff,
      'image': '',
      'category': <String, dynamic>{
        'id': categoryId,
        'name': categoryName,
      },
      'quality_score': confidence,
      'is_processed': (prediction['processed'] as bool?) ?? false,
      'tags': tags,
      'asset_id': asset.id,
    };
  }

  bool _matchesFilters(
    Map<String, dynamic> photo, {
    String? tag,
    bool? isProcessed,
  }) {
    if (isProcessed != null) {
      final bool processed = (photo['is_processed'] as bool?) ?? false;
      if (processed != isProcessed) {
        return false;
      }
    }

    if (tag != null && tag.trim().isNotEmpty) {
      final String wantedTag = tag.trim().toLowerCase();
      final List<dynamic> rawTags = photo['tags'] as List<dynamic>? ?? <dynamic>[];
      final bool hasTag = rawTags.any((dynamic e) {
        if (e is! Map<String, dynamic>) {
          return false;
        }
        final String name = (e['name'] ?? '').toString().toLowerCase().trim();
        return name == wantedTag;
      });
      if (!hasTag) {
        return false;
      }
    }

    return true;
  }
}
