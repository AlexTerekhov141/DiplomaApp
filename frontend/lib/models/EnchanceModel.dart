class EnhanceModel {
  const EnhanceModel({
    this.brightness,
    this.contrast,
    this.saturation,
    this.sharpness,
  });

  factory EnhanceModel.empty() {
    return const EnhanceModel();
  }

  final double? brightness;
  final double? contrast;
  final double? saturation;
  final double? sharpness;

  EnhanceModel copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
    bool clearBrightness = false,
    bool clearContrast = false,
    bool clearSaturation = false,
    bool clearSharpness = false,
  }) {
    return EnhanceModel(
      brightness: clearBrightness ? null : (brightness ?? this.brightness),
      contrast: clearContrast ? null : (contrast ?? this.contrast),
      saturation: clearSaturation ? null : (saturation ?? this.saturation),
      sharpness: clearSharpness ? null : (sharpness ?? this.sharpness),
    );
  }
}