import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../../../bloc/PhotosBloc/bloc.dart';
import '../../../../../bloc/PhotosBloc/events.dart';
import '../../Photo/Photo.dart';

class GalleryPhotoTile extends StatelessWidget {
  const GalleryPhotoTile({
    super.key,
    required this.photo,
    this.photos,
    this.initialIndex,
    this.isInTrash = false,
  });

  final AssetEntity photo;
  final List<AssetEntity>? photos;
  final int? initialIndex;
  final bool isInTrash;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PhotoViewerPage(
              photo: photo,
              photos: photos,
              initialIndex: initialIndex,
            ),
          ),
        );
      },
      onLongPress: () async {
        final bool? confirmed = await showModalBottomSheet<bool>(
          context: context,
          builder: (BuildContext sheetContext) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(isInTrash ? Icons.restore : Icons.delete_outline),
                    title: Text(isInTrash ? 'Restore photo' : 'Move to trash'),
                    onTap: () => Navigator.of(sheetContext).pop(true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('Cancel'),
                    onTap: () => Navigator.of(sheetContext).pop(false),
                  ),
                ],
              ),
            );
          },
        );

        if (confirmed == true) {
          context.read<PhotosBloc>().add(ToggleTrashEvent(photo.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isInTrash ? 'Photo restored' : 'Photo moved to trash',
              ),
            ),
          );
        }
      },
      child: AssetEntityImage(
        photo,
        fit: BoxFit.cover,
      ),
    );
  }
}
