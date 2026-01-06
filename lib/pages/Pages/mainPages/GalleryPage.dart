import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with AutomaticKeepAliveClientMixin {
  List<AssetEntity> _photos = <AssetEntity>[];
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: _photos.length,
            itemBuilder: (BuildContext context, int index) {
              return AssetEntityImage(
                _photos[index],
                fit: BoxFit.cover,
              );
            },
          )
      ),
    );
  }

  Future<void> _loadPhotos() async {
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        orders: <OrderOption>[const OrderOption(type: OrderOptionType.createDate, asc: false)],
      ),
    );

    if (albums.isEmpty) return;
    final AssetPathEntity recentAlbum = albums.first;

    int page = 0;
    const int pageSize = 100;
    final List<AssetEntity> allPhotos = <AssetEntity>[];

    while (true) {
      final List<AssetEntity> photos = await recentAlbum.getAssetListPaged(
        page: page,
        size: pageSize
      );

      if (photos.isEmpty) break;

      allPhotos.addAll(photos);
      page++;
    }

    setState(() => _photos = allPhotos);
  }
}