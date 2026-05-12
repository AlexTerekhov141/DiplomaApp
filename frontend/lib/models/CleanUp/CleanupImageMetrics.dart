class CleanupImageMetrics {
  const CleanupImageMetrics({
    required this.brightness,
    required this.contrast,
    required this.blurScore,
    required this.darkPixelRatio,
    required this.lightPixelRatio,
    required this.width,
    required this.height,
  });

  final double brightness;
  final double contrast;
  final double blurScore;
  final double darkPixelRatio;
  final double lightPixelRatio;
  final int width;
  final int height;
}
