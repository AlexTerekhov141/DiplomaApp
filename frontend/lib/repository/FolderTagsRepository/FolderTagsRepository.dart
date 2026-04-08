import '../../models/Folders/FolderResponse.dart';

abstract class FolderTagsRepository {
  Future<FolderResponse> fetchFolders({bool forceRefresh = false});
}