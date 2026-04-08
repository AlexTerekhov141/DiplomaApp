import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<Uint8List?> pickPhotoBytes() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  if (result == null) return null;
  return result.files.single.bytes;
}


Color scoreColor(BuildContext context, int? score) {
  if (score == null) return Theme.of(context).colorScheme.onSurfaceVariant;
  if (score >= 80) return Colors.green;
  if (score >= 60) return Colors.orange;
  return Colors.red;
}