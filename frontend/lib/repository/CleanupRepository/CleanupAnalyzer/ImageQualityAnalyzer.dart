import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

import '../../../models/CleanUp/CleanupImageMetrics.dart';
import '../../../models/CleanUp/CleanupSeggestionStatus.dart';
import '../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../models/CleanUp/CleanupSuggestionType.dart';

class ImageQualityAnalyzer {
  ImageQualityAnalyzer({
    DateTime? now,
    this.thumbnailSize = const ThumbnailSize.square(128),
    this.thumbnailQuality = 65,
    this.darkBrightnessThreshold = 0.18,
    this.lightBrightnessThreshold = 0.82,
    this.lowContrastThreshold = 0.12,
    this.highBlurThreshold = 0.78,
  }) : _now = now ?? DateTime.now();

  final DateTime _now;
  final ThumbnailSize thumbnailSize;
  final int thumbnailQuality;
  final double darkBrightnessThreshold;
  final double lightBrightnessThreshold;
  final double lowContrastThreshold;
  final double highBlurThreshold;

  Future<CleanupSuggestion?> analyze(AssetEntity asset) async {
    if (asset.type != AssetType.image) {
      return null;
    }

    final CleanupImageMetrics? metrics = await calculateMetrics(asset);
    if (metrics == null) {
      return null;
    }

    final List<String> reasons = <String>[];
    double score = 0;

    if (metrics.blurScore >= highBlurThreshold) {
      reasons.add('Image looks blurry');
      score = math.max(score, 0.72 + metrics.blurScore * 0.18);
    }

    if (metrics.brightness <= darkBrightnessThreshold ||
        metrics.darkPixelRatio >= 0.55) {
      reasons.add('Image is too dark');
      score = math.max(score, 0.64 + metrics.darkPixelRatio * 0.2);
    }

    if (metrics.brightness >= lightBrightnessThreshold ||
        metrics.lightPixelRatio >= 0.45) {
      reasons.add('Image is overexposed');
      score = math.max(score, 0.64 + metrics.lightPixelRatio * 0.22);
    }

    if (metrics.contrast <= lowContrastThreshold) {
      reasons.add('Image has low contrast');
      score = math.max(score, 0.58 + (1 - metrics.contrast) * 0.15);
    }

    if (reasons.isEmpty) {
      return null;
    }

    return CleanupSuggestion(
      assetId: asset.id,
      type: CleanupSuggestionType.badQuality,
      status: CleanupSuggestionStatus.suggested,
      score: score.clamp(0.0, 0.96).toDouble(),
      reason: reasons.join(', '),
      createdAt: _now,
      updatedAt: _now,
      features: <String, dynamic>{
        'brightness': metrics.brightness,
        'contrast': metrics.contrast,
        'blur_score': metrics.blurScore,
        'dark_pixel_ratio': metrics.darkPixelRatio,
        'light_pixel_ratio': metrics.lightPixelRatio,
        'width': metrics.width,
        'height': metrics.height,
      },
    );
  }

  Future<List<CleanupSuggestion>> analyzeAll(
    Iterable<AssetEntity> assets,
  ) async {
    final List<CleanupSuggestion> suggestions = <CleanupSuggestion>[];

    for (final AssetEntity asset in assets) {
      final CleanupSuggestion? suggestion = await analyze(asset);
      if (suggestion != null) {
        suggestions.add(suggestion);
      }
    }

    return suggestions;
  }

  Future<CleanupImageMetrics?> calculateMetrics(AssetEntity asset) async {
    final Uint8List? bytes = await asset.thumbnailDataWithSize(
      thumbnailSize,
      quality: thumbnailQuality,
    );
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null || decoded.width <= 2 || decoded.height <= 2) {
      return null;
    }

    final int width = decoded.width;
    final int height = decoded.height;
    final int pixelCount = width * height;
    final List<double> luminance = List<double>.filled(pixelCount, 0);

    double sum = 0;
    int darkPixels = 0;
    int lightPixels = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final img.Pixel pixel = decoded.getPixel(x, y);
        final double value = _luminance(pixel);
        final int index = y * width + x;
        luminance[index] = value;
        sum += value;
        if (value <= 0.12) {
          darkPixels++;
        }
        if (value >= 0.88) {
          lightPixels++;
        }
      }
    }

    final double brightness = sum / pixelCount;
    double varianceSum = 0;
    for (final double value in luminance) {
      final double delta = value - brightness;
      varianceSum += delta * delta;
    }

    final double contrast = math.sqrt(varianceSum / pixelCount);
    final double laplacianVariance = _laplacianVariance(
      luminance,
      width,
      height,
    );

    return CleanupImageMetrics(
      brightness: brightness,
      contrast: contrast,
      blurScore: _blurScoreFromVariance(laplacianVariance),
      darkPixelRatio: darkPixels / pixelCount,
      lightPixelRatio: lightPixels / pixelCount,
      width: width,
      height: height,
    );
  }

  double _luminance(img.Pixel pixel) {
    final double r = pixel.r.toDouble() / 255.0;
    final double g = pixel.g.toDouble() / 255.0;
    final double b = pixel.b.toDouble() / 255.0;
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  double _laplacianVariance(
    List<double> luminance,
    int width,
    int height,
  ) {
    double sum = 0;
    double sumSquared = 0;
    int count = 0;

    double valueAt(int x, int y) => luminance[y * width + x];

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final double value = 4 * valueAt(x, y) -
            valueAt(x - 1, y) -
            valueAt(x + 1, y) -
            valueAt(x, y - 1) -
            valueAt(x, y + 1);
        sum += value;
        sumSquared += value * value;
        count++;
      }
    }

    if (count == 0) {
      return 0;
    }

    final double mean = sum / count;
    return (sumSquared / count) - mean * mean;
  }

  double _blurScoreFromVariance(double variance) {
    const double sharpVariance = 0.018;
    final double sharpness =
        (variance / sharpVariance).clamp(0.0, 1.0).toDouble();
    return 1.0 - sharpness;
  }
}
