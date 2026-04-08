import 'dart:typed_data';

import 'package:flutter/material.dart';

class EnhancePreview extends StatelessWidget {
  const EnhancePreview({
    super.key,
    required this.editedBytes,
  });

  final Uint8List? editedBytes;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRect(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: editedBytes != null
              ? Image.memory(
            editedBytes!,
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