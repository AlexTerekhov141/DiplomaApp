import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

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
        final bool hasImageUrl = photo.image.trim().isNotEmpty;
        final bool hasAssetId = photo.assetId.trim().isNotEmpty;

        return GestureDetector(
          onTap: () {
            if (hasImageUrl) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NetworkPhotoViewerPage(
                    photo: photo,
                    photos: photos,
                    initialIndex: index,
                  ),
                ),
              );
            } else {
              if (!hasAssetId) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo is unavailable'),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _OfflinePhotoLoader(assetId: photo.assetId),
                ),
              );
            }
          },
          child: ClipRRect(
            child: hasImageUrl
                ? CachedNetworkImage(
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
                  )
                : hasAssetId
                    ? FutureBuilder<AssetEntity?>(
                        future: AssetEntity.fromId(photo.assetId),
                        builder:
                            (BuildContext context, AsyncSnapshot<AssetEntity?> snapshot) {
                          final AssetEntity? asset = snapshot.data;
                          if (asset == null) {
                            return const ColoredBox(
                              color: Colors.black12,
                              child: Center(
                                child: Icon(Icons.photo_outlined),
                              ),
                            );
                          }
                          return AssetEntityImage(
                            asset,
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize.square(300),
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : const ColoredBox(
                        color: Colors.black12,
                        child: Center(
                          child: Icon(Icons.photo_outlined),
                        ),
                      ),
          ),
        );
      },
    );
  }
}

class _OfflinePhotoLoader extends StatelessWidget {
  const _OfflinePhotoLoader({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(assetId),
      builder: (BuildContext context, AsyncSnapshot<AssetEntity?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final AssetEntity? asset = snapshot.data;
        if (asset == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Photo not found on device'),
            ),
          );
        }

        return PhotoViewerPage(photo: asset);
      },
    );
  }
}
