import 'package:flutter/material.dart';

import 'PreviewImage.dart';

class FolderPreview extends StatelessWidget {
  const FolderPreview({
    super.key,
    required this.previewUrls,
  });

  final List<String> previewUrls;

  @override
  Widget build(BuildContext context) {
    if (previewUrls.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.folder_rounded,
          size: 36,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final List<String> urls = previewUrls.take(4).toList();
    final int count = urls.length;

    if (count == 1) {
      return PreviewImage(url: urls[0]);
    }

    if (count == 2) {
      return Row(
        children: <Widget>[
          Expanded(child: PreviewImage(url: urls[0])),
          const SizedBox(width: 2),
          Expanded(child: PreviewImage(url: urls[1])),
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: <Widget>[
          Expanded(child: PreviewImage(url: urls[0])),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(child: PreviewImage(url: urls[1])),
                const SizedBox(height: 2),
                Expanded(child: PreviewImage(url: urls[2])),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: PreviewImage(url: urls[0])),
              const SizedBox(width: 2),
              Expanded(child: PreviewImage(url: urls[1])),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: PreviewImage(url: urls[2])),
              const SizedBox(width: 2),
              Expanded(child: PreviewImage(url: urls[3])),
            ],
          ),
        ),
      ],
    );
  }
}