import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PreviewImage extends StatelessWidget {
  const PreviewImage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('asset:')) {
      final String assetId = url.substring('asset:'.length);
      return FutureBuilder<AssetEntity?>(
        future: AssetEntity.fromId(assetId),
        builder: (BuildContext context, AsyncSnapshot<AssetEntity?> snapshot) {
          final AssetEntity? asset = snapshot.data;
          if (asset == null) {
            return ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(
                  Icons.photo_outlined,
                  size: 16,
                ),
              ),
            );
          }

          return AssetEntityImage(
            asset,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(240),
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 16,
          ),
        ),
      ),
    );
  }
}
