abstract class FoldersEvent {}

class LoadFolders extends FoldersEvent {
  LoadFolders({this.forceRefresh = false});

  final bool forceRefresh;
}

class ClearFolders extends FoldersEvent {}
