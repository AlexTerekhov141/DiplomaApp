abstract class TagsBlocEvent {}

class LoadFolderPhotos extends TagsBlocEvent{
  LoadFolderPhotos({required this.folderId});
  final String folderId;
}

class SearchQueryChanged extends TagsBlocEvent{
  SearchQueryChanged({required this.query});
  final String query;
}

class TagSelected extends TagsBlocEvent{
  TagSelected({required this.tag});
  final String tag;
}

class TagUnselected extends TagsBlocEvent{
  TagUnselected({required this.tag});
  final String tag;
}

class ClearFilters extends TagsBlocEvent{

}