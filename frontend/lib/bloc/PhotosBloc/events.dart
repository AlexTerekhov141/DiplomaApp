import 'package:photo_manager/photo_manager.dart';

abstract class PhotosEvent {}

class PhotosLoadEvent extends PhotosEvent {}

class PhotosSyncToServerEvent extends PhotosEvent {
  PhotosSyncToServerEvent(this.photos);
  final List<AssetEntity> photos;
}

class PhotosResetEvent extends PhotosEvent {}

class PhotosRefreshProcessingStatusEvent extends PhotosEvent {}

class PhotosProcessNextBatchEvent extends PhotosEvent {}

class ToggleFavoriteEvent extends PhotosEvent {
  ToggleFavoriteEvent(this.assetId);
  final String assetId;
}

class LoadFavoritesEvent extends PhotosEvent {}

class LoadTrashEvent extends PhotosEvent {}

class ToggleTrashEvent extends PhotosEvent {
  ToggleTrashEvent(this.assetId);
  final String assetId;
}
