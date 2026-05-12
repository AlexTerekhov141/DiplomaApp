import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../constants/Keys.dart';
import '../../constants/app_config.dart';
import 'PhotosRepository.dart';
import 'PhotosRepositoryConstants.dart';

class PhotosRepositoryImpl implements PhotosRepository {
  PhotosRepositoryImpl({required this.dio, required this.storage});
  final Dio dio;
  final FlutterSecureStorage storage;
  final Map<String, List<Map<String, dynamic>>> _photosCache =
  <String, List<Map<String, dynamic>>>{};

  String get _baseUrl => AppConfig.apiBaseUrl.endsWith('/')
      ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
      : AppConfig.apiBaseUrl;

  String get _photosUrl => '$_baseUrl$photosPath';
  String get _bulkUploadUrl => '$_baseUrl$bulkUploadPath';
  String get _bestPhotosUrl => '$_baseUrl$bestPhotosPath';
  String get _categoriesUrl => '$_baseUrl$categoriesPath';
  String get _tagsUrl => '$_baseUrl$tagsPath';
  String get _refreshUrl => '$_baseUrl$refreshPath';

  Future<String?> _readAccessToken() async {
    return storage.read(key: accessTokenKey);
  }

  bool _isUnauthorized(DioException e) {
    return e.response?.statusCode == 401;
  }

  Future<bool> _tryRefreshToken() async {
    final String? refreshToken =
        await storage.read(key: refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    try {
      final Response<dynamic> response = await dio.post(
        _refreshUrl,
        data: <String, String>{'refresh': refreshToken},
        options: Options(
          headers: const <String, dynamic>{
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final String? newAccess = response.data['access'] as String?;
        final String? newRefresh = response.data['refresh'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          await storage.write(
            key: accessTokenKey,
            value: newAccess,
          );
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await storage.write(
            key: refreshTokenKey,
            value: newRefresh,
          );
        }
        return newAccess != null && newAccess.isNotEmpty;
      }
    } on DioException {
      return false;
    }
    return false;
  }

  Future<T> _withAuthRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      if (_isUnauthorized(e) && await _tryRefreshToken()) {
        return action();
      }
      rethrow;
    }
  }

  Future<Options> _authorizedJsonOptions() async {
    final String? token = await _readAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token');
    }
    return Options(
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Options> _authorizedMultipartOptions() async {
    final String? token = await _readAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token');
    }
    return Options(
      headers: <String, dynamic>{
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPhotos({
    String? tag,
    bool? isProcessed,
    bool forceRefresh = false,
  }) async {
    final String? token = await _readAccessToken();
    final String cacheKey =
        '${token ?? ''}|${tag ?? ''}|${isProcessed?.toString() ?? ''}';
    final List<Map<String, dynamic>>? cached =
    forceRefresh ? null : _photosCache[cacheKey];
    if (cached != null) {
      return List<Map<String, dynamic>>.from(cached);
    }

    final List<Map<String, dynamic>> allPhotos = <Map<String, dynamic>>[];
    String? nextUrl = _photosUrl;
    final Map<String, dynamic> firstQuery = <String, dynamic>{};
    if (tag != null && tag.isNotEmpty) {
      firstQuery['tag'] = tag;
    }
    if (isProcessed != null) {
      firstQuery['is_processed'] = isProcessed.toString();
    }
    Map<String, dynamic>? nextQuery = firstQuery.isEmpty ? null : firstQuery;

    while (nextUrl != null) {
      final Response<dynamic> response = await _withAuthRetry<Response<dynamic>>(
            () async {
          return dio.get(
            nextUrl!,
            queryParameters: nextQuery,
            options: (await _authorizedJsonOptions()).copyWith(
              receiveTimeout: const Duration(
                seconds: receiveTimeoutSeconds,
              ),
            ),
          );
        },
      );

      final dynamic data = response.data;
      if (data is List<dynamic>) {
        allPhotos.addAll(
          data.whereType<Map>().map((dynamic e) {
            return Map<String, dynamic>.from(e as Map);
          }),
        );
        break;
      }

      if (data is Map<String, dynamic>) {
        final List<dynamic> pageItems = data['results'] is List<dynamic>
            ? data['results'] as List<dynamic>
            : <dynamic>[];
        allPhotos.addAll(
          pageItems.whereType<Map>().map((dynamic e) {
            return Map<String, dynamic>.from(e as Map);
          }),
        );

        final dynamic rawNext = data['next'];
        if (rawNext is String && rawNext.isNotEmpty) {
          nextUrl = rawNext;
          nextQuery = null;
        } else {
          nextUrl = null;
        }
      } else {
        break;
      }
    }

    _photosCache[cacheKey] = List<Map<String, dynamic>>.from(allPhotos);
    return allPhotos;
  }

  @override
  Future<List<Map<String, dynamic>>> getBestPhotos() async {
    final Response<dynamic> response = await _withAuthRetry<Response<dynamic>>(
          () async => dio.get(
        _bestPhotosUrl,
        options: await _authorizedJsonOptions(),
      ),
    );
    final List<dynamic> raw = response.data is List<dynamic>
        ? response.data as List<dynamic>
        : <dynamic>[];
    return raw.whereType<Map>().map((dynamic e) {
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final Response<dynamic> response = await _withAuthRetry<Response<dynamic>>(
          () async => dio.get(
        _categoriesUrl,
        options: await _authorizedJsonOptions(),
      ),
    );
    final List<dynamic> raw = response.data is List<dynamic>
        ? response.data as List<dynamic>
        : <dynamic>[];
    return raw.whereType<Map>().map((dynamic e) {
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    final Response<dynamic> response = await _withAuthRetry<Response<dynamic>>(
          () async => dio.get(
        _tagsUrl,
        options: await _authorizedJsonOptions(),
      ),
    );
    final List<dynamic> raw = response.data is List<dynamic>
        ? response.data as List<dynamic>
        : <dynamic>[];
    return raw.whereType<Map>().map((dynamic e) {
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }

  Future<int> _getRemotePhotosCount() async {
    final Response<dynamic> response = await _withAuthRetry<Response<dynamic>>(
          () async => dio.get(
        _photosUrl,
        options: (await _authorizedJsonOptions()).copyWith(
          receiveTimeout: const Duration(
            seconds: receiveTimeoutSeconds,
          ),
        ),
      ),
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      final dynamic count = data['count'];
      if (count is int) {
        return count;
      }
      return int.tryParse(count?.toString() ?? '') ?? 0;
    }
    if (data is List<dynamic>) {
      return data.length;
    }
    return 0;
  }

  @override
  Future<Map<String, int>> getRemoteProcessingStats() async {
    final Response<dynamic> totalResponse = await _withAuthRetry<Response<dynamic>>(
          () async => dio.get(
        _photosUrl,
        options: (await _authorizedJsonOptions()).copyWith(
          receiveTimeout: const Duration(
            seconds: receiveTimeoutSeconds,
          ),
        ),
      ),
    );
    final Response<dynamic> processedResponse =
    await _withAuthRetry<Response<dynamic>>(
          () async => dio.get(
        _photosUrl,
        queryParameters: const <String, dynamic>{'is_processed': 'true'},
        options: (await _authorizedJsonOptions()).copyWith(
          receiveTimeout: const Duration(
            seconds: receiveTimeoutSeconds,
          ),
        ),
      ),
    );

    int extractCount(dynamic data) {
      if (data is Map<String, dynamic>) {
        final dynamic count = data['count'];
        if (count is int) {
          return count;
        }
        return int.tryParse(count?.toString() ?? '') ?? 0;
      }
      if (data is List<dynamic>) {
        return data.length;
      }
      return 0;
    }

    final int total = extractCount(totalResponse.data);
    final int processed = extractCount(processedResponse.data);
    final int pending = total - processed > 0 ? total - processed : 0;
    return <String, int>{
      'total': total,
      'processed': processed,
      'pending': pending,
    };
  }

  @override
  Future<int> bulkUploadLocalPhotos(List<AssetEntity> assets) async {
    if (assets.isEmpty) {
      return 0;
    }

    Set<String> uploadedIds = await _readUploadedAssetIds();

    if (uploadedIds.isNotEmpty) {
      final int remoteCount = await _getRemotePhotosCount();
      if (remoteCount == 0) {
        uploadedIds = <String>{};
        await _writeUploadedAssetIds(uploadedIds);
      }
    }

    final List<AssetEntity> pendingAssets = assets
        .where((AssetEntity asset) => !uploadedIds.contains(asset.id))
        .toList();

    if (pendingAssets.isEmpty) {
      return 0;
    }

    int uploadedTotal = 0;
    for (int i = 0; i < pendingAssets.length; i += uploadChunkSize) {
      final int end = (i + uploadChunkSize < pendingAssets.length) ? i + uploadChunkSize : pendingAssets.length;
      final List<AssetEntity> chunk = pendingAssets.sublist(i, end);
      final List<_UploadItem> chunkItems = <_UploadItem>[];

      for (final AssetEntity asset in chunk) {
        final File? file = await asset.file;
        if (file == null || !file.existsSync()) {
          continue;
        }
        final String fileName = file.path.split(Platform.pathSeparator).last;
        chunkItems.add(
          _UploadItem(
            assetId: asset.id,
            filePath: file.path,
            fileName: fileName,
          ),
        );
      }

      if (chunkItems.isEmpty) {
        continue;
      }

      try {
        await _uploadItems(chunkItems);
        uploadedTotal += chunkItems.length;
        uploadedIds.addAll(chunkItems.map((_UploadItem item) => item.assetId));
      } on DioException catch (e) {
        if (e.response?.statusCode != 400) {
          rethrow;
        }

        for (final _UploadItem item in chunkItems) {
          try {
            await _uploadItems(<_UploadItem>[item]);
            uploadedTotal++;
            uploadedIds.add(item.assetId);
          } on DioException {
            continue;
          }
        }
      }

      await _writeUploadedAssetIds(uploadedIds);
      _invalidatePhotosCache();
    }
    return uploadedTotal;
  }

  @override
  Future<int> processNextBatch({int batchSize = 20}) async {
    return 0;
  }

  Future<void> _uploadItems(List<_UploadItem> items) async {
    final FormData data = FormData();
    for (final _UploadItem item in items) {
      data.files.add(
        MapEntry<String, MultipartFile>(
          'images',
          await MultipartFile.fromFile(item.filePath, filename: item.fileName),
        ),
      );
    }

    await _withAuthRetry<Response<dynamic>>(
      () async => dio.post(
        _bulkUploadUrl,
        data: data,
        options: await _authorizedMultipartOptions(),
      ),
    );
  }

  void _invalidatePhotosCache() {
    _photosCache.clear();
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

  Future<void> _writeStringSet(String key, Set<String> ids) async {
    await storage.write(key: key, value: jsonEncode(ids.toList()));
  }

  Future<Set<String>> _readUploadedAssetIds() async {
    return _readStringSet(uploadedAssetIdsKey);
  }

  Future<void> _writeUploadedAssetIds(Set<String> ids) async {
    await _writeStringSet(
      uploadedAssetIdsKey,
      ids,
    );
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    return _readStringSet(favoritePhotoIdsKey);
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

  @override
  Future<bool> isFavorite(String assetId) async {
    final Set<String> currentIds = await getFavoriteIds();
    return currentIds.contains(assetId);
  }
  @override
  Future<Set<String>> getTrashedIds() async {
    return _readStringSet(trashedPhotoIdsKey);
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

  @override
  Future<bool> isTrashed(String assetId) async {
    final Set<String> currentIds = await getTrashedIds();
    return currentIds.contains(assetId);
  }
}

class _UploadItem {
  const _UploadItem({
    required this.assetId,
    required this.filePath,
    required this.fileName,
  });

  final String assetId;
  final String filePath;
  final String fileName;
}
