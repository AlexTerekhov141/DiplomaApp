import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../Functions/Functions.dart';
import 'EnchanceActionButton.dart';

class EnhanceToolbar extends StatelessWidget {
  const EnhanceToolbar({
    super.key,
    required this.onImagePicked,
    required this.onAutoPressed,
    required this.onResetPressed,
    required this.onSaveCopyPressed,
  });

  final ValueChanged<Uint8List> onImagePicked;
  final VoidCallback onAutoPressed;
  final VoidCallback onResetPressed;
  final VoidCallback onSaveCopyPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          EnhanceActionButton(
            text: 'Pick Photo',
            onPressed: () async {
              final Uint8List? bytes = await pickPhotoBytes(context);
              if (bytes != null) {
                onImagePicked(bytes);
              }
            },
          ),
          const SizedBox(width: 8),
          EnhanceActionButton(
            text: 'Auto',
            onPressed: onAutoPressed,
          ),
          const SizedBox(width: 8),
          EnhanceActionButton(
            text: 'Reset',
            onPressed: onResetPressed,
          ),
          const SizedBox(width: 8),
          EnhanceActionButton(
            text: 'Save copy',
            onPressed: onSaveCopyPressed,
          ),
        ],
      ),
    );
  }
}
