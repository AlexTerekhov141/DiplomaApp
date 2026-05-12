import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

Future<void> enhanceSaver(Uint8List editedBytes) async {
  final PermissionState permission = await PhotoManager.requestPermissionExtend();
  if (!permission.hasAccess) {
    throw Exception('Gallery permission denied');
  }

  await PhotoManager.editor.saveImage(
    editedBytes,
    filename: 'enhance_${DateTime.now().millisecondsSinceEpoch}.jpg',
    title: 'Enhanced photo',
    relativePath: 'Pictures/DiplomaApp',
  );
}
