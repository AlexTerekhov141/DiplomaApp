import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../repository/PhotosRepository.dart';
import 'events.dart';
import 'states.dart';

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  PhotosBloc({required this.photosRepository}) : super(PhotosState.initial()) {
    on<PhotosLoadEvent>(_onLoadPhotos);
    on<PhotosSyncToServerEvent>(_onSyncPhotosToServer);
    on<PhotosResetEvent>(_onReset);
  }
  final PhotosRepository photosRepository;

  Future<void> _onLoadPhotos(
      PhotosLoadEvent event,
      Emitter<PhotosState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (isDesktop) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Photos are not supported on desktop yet',
      ));
      return;
    }

    try {
      final PermissionState permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Permission denied',
        ));
        return;
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: const <OrderOption>[
            OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

      if (albums.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final AssetPathEntity recentAlbum = albums.first;

      int page = 0;
      const int pageSize = 100;
      final List<AssetEntity> allPhotos = <AssetEntity>[];

      while (true) {
        final List<AssetEntity> photos = await recentAlbum.getAssetListPaged(
          page: page,
          size: pageSize,
        );

        if (photos.isEmpty) {
          break;
        }

        allPhotos.addAll(photos);
        page++;
      }

      emit(
        state.copyWith(
          photos: allPhotos,
          isLoading: false,
          error: null,
        ),
      );
      add(PhotosSyncToServerEvent(allPhotos));
    } on MissingPluginException {
      emit(state.copyWith(
        isLoading: false,
        error: 'Photos are not available on this platform',
      ));
    }
  }

  Future<void> _onSyncPhotosToServer(
    PhotosSyncToServerEvent event,
    Emitter<PhotosState> emit,
  ) async {
    if (event.photos.isEmpty) {
      return;
    }

    emit(state.copyWith(isSyncing: true, syncError: null));

    try {
      final int uploaded = await photosRepository.bulkUploadLocalPhotos(event.photos);
      emit(state.copyWith(
        isSyncing: false,
        uploadedCount: state.uploadedCount + uploaded,
        syncError: null,
      ));
    } catch (e) {
      final String message = e.toString();
      final bool noToken = message.contains('No token');
      emit(state.copyWith(
        isSyncing: false,
        syncError: noToken ? null : message,
      ));
    }
  }

  void _onReset(
    PhotosResetEvent event,
    Emitter<PhotosState> emit,
  ) {
    emit(PhotosState.initial());
  }
}
