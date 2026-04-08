import 'dart:typed_data';

import 'package:flutter/material.dart';

class PhotoRoastPreview extends StatelessWidget {
  const PhotoRoastPreview({
    super.key,
    required this.imageBytes,
  });

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRect(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: imageBytes != null
              ? Image.memory(
            imageBytes!,
            fit: BoxFit.contain,
            width: double.infinity,
          )
              : const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.photo_outlined, size: 48),
              SizedBox(height: 8),
              Text('Pick photo'),
            ],
          ),
        ),
      ),
    );
  }
}