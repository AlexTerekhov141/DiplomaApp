import '../models/Folders/Folder.dart';
import '../models/Folders/FolderResponse.dart';

class FolderTagsRepository {
  Future<FolderResponse> fetchFolders() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return FolderResponse(
      folders: <Folder>[
        Folder(id: '1', name: 'Favourites', photosCount: 120),
        Folder(id: '2', name: 'People', photosCount: 340),
        Folder(id: '3', name: 'Nature', photosCount: 89),
        Folder(id: '4', name: 'Food', photosCount: 56),
      ],
    );
  }
}
