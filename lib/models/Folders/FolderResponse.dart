import 'Folder.dart';

class FolderResponse {

  FolderResponse({required this.folders});

  factory FolderResponse.fromJson(List<dynamic> json) {
    return FolderResponse(
      folders: json.map((e) => Folder.fromJson(e)).toList(),
    );
  }
  final List<Folder> folders;
}
