import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class EnchanceEvent extends Equatable {
  const EnchanceEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class EnchanceImageLoaded extends EnchanceEvent {
  const EnchanceImageLoaded(this.bytes);

  final Uint8List bytes;

  @override
  List<Object?> get props => <Object?>[bytes];
}

class EnchanceAutoApplied extends EnchanceEvent {
  const EnchanceAutoApplied();
}

class EnchanceAdjustmentsChanged extends EnchanceEvent {
  const EnchanceAdjustmentsChanged({
    this.brightness,
    this.contrast,
    this.saturation,
    this.sharpness,
  });

  final double? brightness;
  final double? contrast;
  final double? saturation;
  final double? sharpness;

  @override
  List<Object?> get props => <Object?>[brightness, contrast, saturation, sharpness];
}

class EnchanceResetRequested extends EnchanceEvent {
  const EnchanceResetRequested();
}

class EnchanceSaveCopyRequested extends EnchanceEvent {
  const EnchanceSaveCopyRequested();
}

class EnchanceErrorCleared extends EnchanceEvent {
  const EnchanceErrorCleared();
}
