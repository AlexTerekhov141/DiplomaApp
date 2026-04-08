import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../../../Routes/routes.gr.dart';



class GalleryPhotoTile extends StatelessWidget {
  const GalleryPhotoTile({
    super.key,
    required this.photo,
  });

  final AssetEntity photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(
          PhotoViewerRoute(photo: photo),
        );
      },
      child: AssetEntityImage(
        photo,
        fit: BoxFit.cover,
      ),
    );
  }
}