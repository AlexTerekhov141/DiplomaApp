import 'package:flutter/material.dart';

class PreviewImage extends StatelessWidget {
  const PreviewImage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
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