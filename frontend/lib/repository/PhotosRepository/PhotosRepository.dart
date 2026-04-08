import 'package:photo_manager/photo_manager.dart';

abstract class PhotosRepository {
  Future<List<Map<String, dynamic>>> getPhotos({
    String? tag,
    bool? isProcessed,
    bool forceRefresh = false,
  });

  Future<List<Map<String, dynamic>>> getBestPhotos();

  Future<List<Map<String, dynamic>>> getCategories();

  Future<List<Map<String, dynamic>>> getTags();

  Future<Map<String, int>> getRemoteProcessingStats();

  Future<int> bulkUploadLocalPhotos(List<AssetEntity> assets);
}