import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';

@RoutePage()
class PhotoViewerPage extends StatelessWidget {

  const PhotoViewerPage({super.key, required this.photo});
  final AssetEntity photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: PhotoView(
        imageProvider: AssetEntityImageProvider(
          photo,
          isOriginal: true,
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}
