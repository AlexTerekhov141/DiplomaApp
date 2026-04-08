import 'package:flutter/material.dart';

import '../../../../../bloc/EnchanceBloc/event.dart';
import '../../../../../bloc/EnchanceBloc/state.dart';
import '../../../../../models/EnchanceModel.dart';
import 'EnchanceSliderTile.dart';


class EnhanceSlidersCard extends StatelessWidget {
  const EnhanceSlidersCard({
    super.key,
    required this.state,
    required this.model,
    required this.onDraftChanged,
    required this.onEvent,
  });

  final EnchanceState state;
  final EnhanceModel model;
  final ValueChanged<EnhanceModel> onDraftChanged;
  final ValueChanged<EnchanceEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          EnhanceSliderTile(
            text: 'Brightness',
            value: model.brightness ?? state.adjustments.brightness,
            onChanged: (double value) {
              onDraftChanged(model.copyWith(brightness: value));
            },
            onChangeEnd: (double value) {
              onDraftChanged(
                model.copyWith(clearBrightness: true),
              );
              onEvent(
                EnchanceAdjustmentsChanged(brightness: value),
              );
            },
          ),
          EnhanceSliderTile(
            text: 'Contrast',
            value: model.contrast ?? state.adjustments.contrast,
            onChanged: (double value) {
              onDraftChanged(model.copyWith(contrast: value));
            },
            onChangeEnd: (double value) {
              onDraftChanged(
                model.copyWith(clearContrast: true),
              );
              onEvent(
                EnchanceAdjustmentsChanged(contrast: value),
              );
            },
          ),
          EnhanceSliderTile(
            text: 'Saturation',
            value: model.saturation ?? state.adjustments.saturation,
            onChanged: (double value) {
              onDraftChanged(model.copyWith(saturation: value));
            },
            onChangeEnd: (double value) {
              onDraftChanged(
                model.copyWith(clearSaturation: true),
              );
              onEvent(
                EnchanceAdjustmentsChanged(saturation: value),
              );
            },
          ),
          EnhanceSliderTile(
            text: 'Sharpness',
            value: model.sharpness ?? state.adjustments.sharpness,
            onChanged: (double value) {
              onDraftChanged(model.copyWith(sharpness: value));
            },
            onChangeEnd: (double value) {
              onDraftChanged(
                model.copyWith(clearSharpness: true),
              );
              onEvent(
                EnchanceAdjustmentsChanged(sharpness: value),
              );
            },
          ),
        ],
      ),
    );
  }
}