import 'package:flutter/material.dart';

import '../../../../../models/Photo.dart';
import '../../Photo/Photo.dart';


class FolderPhotosGrid extends StatelessWidget {
  const FolderPhotosGrid({
    super.key,
    required this.photos,
    required this.crossAxisCount,
  });

  final List<Photo> photos;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (_, int index) {
        final Photo photo = photos[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NetworkPhotoViewerPage(photo: photo),
              ),
            );
          },
          child: ClipRRect(
            child: Image.network(
              photo.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black12,
                child: Center(
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}