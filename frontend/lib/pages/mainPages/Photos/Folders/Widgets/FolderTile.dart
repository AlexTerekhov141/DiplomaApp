import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../Routes/routes.gr.dart';
import '../../../../../models/Folders/Folder.dart';
import 'FolderPreview.dart';


class FolderTile extends StatelessWidget {
  const FolderTile({
    super.key,
    required this.folder,
  });

  final Folder folder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const BorderRadius radius = BorderRadius.all(Radius.circular(16));

    return InkWell(
      borderRadius: radius,
      onTap: () {
        context.router.push(FolderDetailsRoute(folder: folder));
      },
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: radius,
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FolderPreview(previewUrls: folder.previewUrls),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0x00000000),
                        Color(0xB3000000),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${folder.photosCount} photos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}