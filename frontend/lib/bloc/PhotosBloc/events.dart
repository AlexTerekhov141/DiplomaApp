import 'package:photo_manager/photo_manager.dart';

abstract class PhotosEvent {}

class PhotosLoadEvent extends PhotosEvent {}

class PhotosSyncToServerEvent extends PhotosEvent {
  PhotosSyncToServerEvent(this.photos);
  final List<AssetEntity> photos;
}

class PhotosResetEvent extends PhotosEvent {}
