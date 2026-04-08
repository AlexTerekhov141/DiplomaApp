import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'GalleryPhotoTile.dart';


class GalleryPhotosGrid extends StatelessWidget {
  const GalleryPhotosGrid({
    super.key,
    required this.photos,
    required this.crossAxisCount,
  });

  final List<AssetEntity> photos;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (_, int index) {
          return GalleryPhotoTile(
            photo: photos[index],
          );
        },
        childCount: photos.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
    );
  }
}