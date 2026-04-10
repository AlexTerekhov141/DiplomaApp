import 'package:cached_network_image/cached_network_image.dart';
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
                builder: (_) => NetworkPhotoViewerPage(
                  photo: photo,
                  photos: photos,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl: photo.image,
              cacheKey: 'photo_${photo.id}',
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (_, __) => const ColoredBox(
                color: Colors.black12,
                child: SizedBox.expand(),
              ),
              errorWidget: (_, __, ___) => const ColoredBox(
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
