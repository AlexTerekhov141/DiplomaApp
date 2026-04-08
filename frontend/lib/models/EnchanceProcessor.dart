import 'dart:typed_data';
import 'package:image/image.dart' as im;
import '../../../bloc/EnchanceBloc/state.dart';

Future<Uint8List> enhanceProcessor(
    Uint8List originalBytes,
    EnchanceAdjustments a,
    ) async {
  final im.Image? src = im.decodeImage(originalBytes);
  if (src == null) throw Exception('Invalid image bytes');

  final im.Image out = src.clone();

  final double b = a.brightness * 255.0;
  final double c = 1.0 + a.contrast;
  final double s = 1.0 + a.saturation;

  for (int y = 0; y < out.height; y++) {
    for (int x = 0; x < out.width; x++) {
      final im.Pixel p = out.getPixel(x, y);
      double r = p.r.toDouble();
      double g = p.g.toDouble();
      double bl = p.b.toDouble();

      r += b; g += b; bl += b;

      r = ((r - 128.0) * c) + 128.0;
      g = ((g - 128.0) * c) + 128.0;
      bl = ((bl - 128.0) * c) + 128.0;

      final double gray = 0.299 * r + 0.587 * g + 0.114 * bl;
      r = gray + (r - gray) * s;
      g = gray + (g - gray) * s;
      bl = gray + (bl - gray) * s;

      out.setPixelRgba(
        x,
        y,
        r.clamp(0, 255).toInt(),
        g.clamp(0, 255).toInt(),
        bl.clamp(0, 255).toInt(),
        p.a.toInt(),
      );
    }
  }

  if (a.sharpness.abs() > 0.001) {
    final im.Image blurred = im.gaussianBlur(out.clone(), radius: 1);
    final double amt = a.sharpness.clamp(0.0, 1.0);

    for (int y = 0; y < out.height; y++) {
      for (int x = 0; x < out.width; x++) {
        final im.Pixel o = out.getPixel(x, y);
        final im.Pixel blr = blurred.getPixel(x, y);

        final int r = (o.r + (o.r - blr.r) * amt).clamp(0, 255).toInt();
        final int g = (o.g + (o.g - blr.g) * amt).clamp(0, 255).toInt();
        final int b2 = (o.b + (o.b - blr.b) * amt).clamp(0, 255).toInt();

        out.setPixelRgba(x, y, r, g, b2, o.a.toInt());
      }
    }
  }

  return Uint8List.fromList(im.encodeJpg(out, quality: 95));
}
