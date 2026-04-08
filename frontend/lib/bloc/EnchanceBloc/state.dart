import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class EnchanceState extends Equatable {
  const EnchanceState({
    required this.originalBytes,
    required this.editedBytes,
    required this.adjustments,
    this.isProcessing = false,
    this.isSaving = false,
    this.error,
  });

  factory EnchanceState.initial() {
    return EnchanceState(
      originalBytes: null,
      editedBytes: null,
      adjustments: EnchanceAdjustments.initial(),
    );
  }

  final Uint8List? originalBytes;
  final Uint8List? editedBytes;
  final EnchanceAdjustments adjustments;
  final bool isProcessing;
  final bool isSaving;
  final String? error;

  bool get hasImage => originalBytes != null && originalBytes!.isNotEmpty;

  EnchanceState copyWith({
    Uint8List? originalBytes,
    bool keepOriginalBytes = true,
    Uint8List? editedBytes,
    bool keepEditedBytes = true,
    EnchanceAdjustments? adjustments,
    bool? isProcessing,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return EnchanceState(
      originalBytes: keepOriginalBytes ? (originalBytes ?? this.originalBytes) : null,
      editedBytes: keepEditedBytes ? (editedBytes ?? this.editedBytes) : null,
      adjustments: adjustments ?? this.adjustments,
      isProcessing: isProcessing ?? this.isProcessing,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    originalBytes,
    editedBytes,
    adjustments,
    isProcessing,
    isSaving,
    error,
  ];
}

class EnchanceAdjustments extends Equatable {
  const EnchanceAdjustments({
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.sharpness,
  });

  factory EnchanceAdjustments.initial() {
    return const EnchanceAdjustments(
      brightness: 0,
      contrast: 0,
      saturation: 0,
      sharpness: 0,
    );
  }

  factory EnchanceAdjustments.autoPreset() {
    return const EnchanceAdjustments(
      brightness: 0.10,
      contrast: 0.14,
      saturation: 0.08,
      sharpness: 0.18,
    );
  }

  final double brightness;
  final double contrast;
  final double saturation;
  final double sharpness;

  EnchanceAdjustments copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
  }) {
    return EnchanceAdjustments(
      brightness: _clamp(brightness ?? this.brightness),
      contrast: _clamp(contrast ?? this.contrast),
      saturation: _clamp(saturation ?? this.saturation),
      sharpness: _clamp(sharpness ?? this.sharpness),
    );
  }

  static double _clamp(double value) {
    if (value < -1) return -1;
    if (value > 1) return 1;
    return value;
  }

  @override
  List<Object?> get props => <Object?>[brightness, contrast, saturation, sharpness];
}
