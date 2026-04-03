import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';

import '../../../models/Photo.dart';

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

class NetworkPhotoViewerPage extends StatelessWidget {
  const NetworkPhotoViewerPage({super.key, required this.photo});
  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PhotoView(
            imageProvider: NetworkImage(photo.image),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photo.tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, int index) {
                return Chip(label: Text(photo.tags[index]));
              }
              )
          )
        ],
      )
    );
  }
}
