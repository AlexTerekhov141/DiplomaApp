import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../Enchance/Widgets/EnchanceActionButton.dart';
import '../../Functions/Functions.dart';

class PhotoRoastToolbar extends StatelessWidget {
  const PhotoRoastToolbar({
    super.key,
    required this.onImagePicked,
    required this.onAnalyzePressed,
    required this.onResetPressed,
  });

  final ValueChanged<Uint8List> onImagePicked;
  final VoidCallback onAnalyzePressed;
  final VoidCallback onResetPressed;

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
            text: 'Analyze again',
            onPressed: onAnalyzePressed,
          ),
          const SizedBox(width: 8),
          EnhanceActionButton(
            text: 'Reset',
            onPressed: onResetPressed,
          ),
        ],
      ),
    );
  }
}
