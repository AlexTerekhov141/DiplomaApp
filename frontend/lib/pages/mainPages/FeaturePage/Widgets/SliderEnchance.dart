import 'package:flutter/material.dart';

class SliderEnchance extends StatelessWidget {
  const SliderEnchance({
    required this.text,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String text;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text),
        Slider(
          label: text,
          value: value,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          min: -1,
          max: 1,
        ),
      ],
    );
  }
}
