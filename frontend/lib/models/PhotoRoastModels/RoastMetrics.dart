class RoastMetrics {
  const RoastMetrics({
    required this.brightness,
    required this.contrast,
    required this.sharpness,
    required this.clippingHighlights,
    required this.clippingShadows,
  });

  final double brightness;
  final double contrast;
  final double sharpness;
  final double clippingHighlights;
  final double clippingShadows;
}
