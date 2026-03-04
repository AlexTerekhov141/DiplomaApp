import 'package:dio/dio.dart';

import '../models/Folders/Folder.dart';
import '../models/Folders/FolderResponse.dart';
import 'PhotosRepository.dart';

class FolderTagsRepository {
  FolderTagsRepository(this.photosRepository);
  final PhotosRepository photosRepository;

  Future<FolderResponse> fetchFolders() async {
    try {
      final List<Map<String, dynamic>> photos = await photosRepository.getPhotos();
      final Map<String, Folder> grouped = <String, Folder>{};

      for (final Map<String, dynamic> photo in photos) {
        final dynamic rawCategory = photo['category'];
        final Map<String, dynamic>? category = rawCategory is Map<String, dynamic>
            ? rawCategory
            : null;

        final String folderId = category?['id']?.toString() ?? 'uncategorized';
        final String folderName = category?['name']?.toString() ?? 'Uncategorized';

        final Folder? existing = grouped[folderId];
        if (existing == null) {
          grouped[folderId] = Folder(
            id: folderId,
            name: folderName,
            photosCount: 1,
          );
        } else {
          grouped[folderId] = Folder(
            id: existing.id,
            name: existing.name,
            photosCount: existing.photosCount + 1,
          );
        }
      }

      final List<Folder> folders = grouped.values.toList()
        ..sort((Folder a, Folder b) => b.photosCount.compareTo(a.photosCount));

      return FolderResponse(folders: folders);
    } catch (e) {
      final String message = e.toString();
      if (message.contains('No token')) {
        return FolderResponse(folders: const <Folder>[]);
      }
      if (e is DioException &&
          (e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionTimeout)) {
        return FolderResponse(folders: const <Folder>[]);
      }
      rethrow;
    }
  }
}
