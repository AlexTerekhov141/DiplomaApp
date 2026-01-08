import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'events.dart';
import 'states.dart';

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  PhotosBloc() : super(PhotosState.initial()) {
    on<PhotosLoadEvent>(_onLoadPhotos);
  }

  Future<void> _onLoadPhotos(
      PhotosLoadEvent event,
      Emitter<PhotosState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

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

      if (photos.isEmpty) break;

      allPhotos.addAll(photos);
      page++;
    }

    emit(
      state.copyWith(
        photos: allPhotos,
        isLoading: false,
      ),
    );
  }
}
