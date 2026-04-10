import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../models/Folders/Folder.dart';
import '../../../../models/Photo.dart';
import '../../../../repository/FolderTagsRepository/FolderTagsRepository.dart';
import '../../../../repository/PhotosRepository/PhotosRepository.dart';

Future<Uint8List?> pickPhotoBytes(BuildContext context) async {
  final FolderTagsRepository folderRepository = GetIt.I<FolderTagsRepository>();
  final PhotosRepository photosRepository = GetIt.I<PhotosRepository>();
  final Dio dio = GetIt.I<Dio>();

  final List<Folder> folders =
      (await folderRepository.fetchFolders(forceRefresh: false)).folders;
  if (folders.isEmpty) {
    return null;
  }

  final Folder? selectedFolder = await showModalBottomSheet<Folder>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FolderPickerSheet(folders: folders),
  );
  if (selectedFolder == null) {
    return null;
  }

  final List<Map<String, dynamic>> rawPhotos =
      await photosRepository.getPhotos(isProcessed: true);
  final List<Photo> folderPhotos = rawPhotos
      .map(Photo.fromJson)
      .where((Photo photo) {
        if (selectedFolder.id == 'uncategorized') {
          return photo.categoryId == null || photo.categoryId!.isEmpty;
        }
        return photo.categoryId == selectedFolder.id;
      })
      .toList();
  if (folderPhotos.isEmpty) {
    return null;
  }

  final Photo? selectedPhoto = await showModalBottomSheet<Photo>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PhotoPickerSheet(
      folderName: selectedFolder.name,
      photos: folderPhotos,
    ),
  );
  if (selectedPhoto == null) {
    return null;
  }

  try {
    final Response<List<int>> response = await dio.get<List<int>>(
      selectedPhoto.image,
      options: Options(responseType: ResponseType.bytes),
    );
    final List<int>? bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    return Uint8List.fromList(bytes);
  } catch (_) {
    return null;
  }
}

class _FolderPickerSheet extends StatelessWidget {
  const _FolderPickerSheet({required this.folders});

  final List<Folder> folders;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Choose folder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: folders.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, int index) {
                  final Folder folder = folders[index];
                  return ListTile(
                    title: Text(folder.name),
                    subtitle: Text('${folder.photosCount} photos'),
                    onTap: () => Navigator.of(context).pop(folder),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPickerSheet extends StatelessWidget {
  const _PhotoPickerSheet({
    required this.folderName,
    required this.photos,
  });

  final String folderName;
  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ScrollController controller) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                Text(
                  folderName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    controller: controller,
                    itemCount: photos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemBuilder: (_, int index) {
                      final Photo photo = photos[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(photo),
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
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Color scoreColor(BuildContext context, int? score) {
  if (score == null) return Theme.of(context).colorScheme.onSurfaceVariant;
  if (score >= 80) return Colors.green;
  if (score >= 60) return Colors.orange;
  return Colors.red;
}
