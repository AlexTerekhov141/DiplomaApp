import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../../models/Photo.dart';
import '../../../../models/PhotoRoastModels/QualityPhotoGroup.dart';
import '../../Photos/Photo/Photo.dart';

@RoutePage()
class PhotoRoastDetailsPage extends StatelessWidget {
  const PhotoRoastDetailsPage({super.key, required this.group});

  final QualityPhotoGroup group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.title)),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: group.photos.length,
        itemBuilder: (BuildContext context, int index) {
          final Photo photo = group.photos[index];
          final bool hasImageUrl = photo.image.trim().isNotEmpty;
          final bool hasAssetId = photo.assetId.trim().isNotEmpty;

          return GestureDetector(
            onTap: () {
              if (hasImageUrl) {
                final List<Photo> viewerPhotos = group.photos
                    .where((Photo p) => p.image.trim().isNotEmpty)
                    .toList();
                final int viewerIndex = _indexOfPhoto(viewerPhotos, photo);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NetworkPhotoViewerPage(
                      photo: photo,
                      photos: viewerPhotos,
                      initialIndex: viewerIndex,
                    ),
                  ),
                );
              } else {
                if (!hasAssetId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo is unavailable')),
                  );
                  return;
                }
                final List<Photo> viewerPhotos = group.photos
                    .where((Photo p) => p.assetId.trim().isNotEmpty)
                    .toList();
                final int viewerIndex = _indexOfPhoto(viewerPhotos, photo);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _OfflinePhotoLoader(
                      photos: viewerPhotos,
                      initialIndex: viewerIndex,
                    ),
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
                        child: Center(child: Icon(Icons.broken_image_outlined)),
                      ),
                    )
                  : hasAssetId
                  ? FutureBuilder<AssetEntity?>(
                      future: AssetEntity.fromId(photo.assetId),
                      builder:
                          (BuildContext context, AsyncSnapshot<AssetEntity?> snapshot,) {
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
                      child: Center(child: Icon(Icons.photo_outlined)),
                    ),
            ),
          );
        },
      ),
    );
  }
}

int _indexOfPhoto(List<Photo> photos, Photo selectedPhoto) {
  final int byIdentity = photos.indexWhere(
    (Photo photo) => identical(photo, selectedPhoto),
  );
  if (byIdentity >= 0) {
    return byIdentity;
  }

  final int byId = photos.indexWhere(
    (Photo photo) =>
        photo.id == selectedPhoto.id &&
        photo.assetId == selectedPhoto.assetId &&
        photo.image == selectedPhoto.image,
  );
  return byId >= 0 ? byId : 0;
}

class _OfflinePhotoLoader extends StatelessWidget {
  const _OfflinePhotoLoader({required this.photos, required this.initialIndex});

  final List<Photo> photos;
  final int initialIndex;

  Future<List<AssetEntity>> _loadAssets() async {
    final List<AssetEntity> assets = <AssetEntity>[];
    for (final Photo photo in photos) {
      final String assetId = photo.assetId.trim();
      if (assetId.isEmpty) {
        continue;
      }

      final AssetEntity? asset = await AssetEntity.fromId(assetId);
      if (asset != null) {
        assets.add(asset);
      }
    }
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetEntity>>(
      future: _loadAssets(),
      builder:
          (BuildContext context, AsyncSnapshot<List<AssetEntity>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final List<AssetEntity> assets = snapshot.data ?? <AssetEntity>[];
            if (assets.isEmpty) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(child: Text('Photos not found on device')),
              );
            }

            final String selectedAssetId =
                initialIndex >= 0 && initialIndex < photos.length
                ? photos[initialIndex].assetId
                : assets.first.id;
            final int resolvedIndex = assets.indexWhere(
              (AssetEntity asset) => asset.id == selectedAssetId,
            );
            final int safeIndex = resolvedIndex >= 0 ? resolvedIndex : 0;

            return PhotoViewerPage(
              photo: assets[safeIndex],
              photos: assets,
              initialIndex: safeIndex,
            );
          },
    );
  }
}
