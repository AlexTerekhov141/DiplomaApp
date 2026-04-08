import 'package:flutter/material.dart';

class EnhanceSliderTile extends StatelessWidget {
  const EnhanceSliderTile({
    super.key,
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
      children: <Widget>[
        ListTile(
          title: Text(text),
          subtitle: Slider(
            value: value,
            min: 0,
            max: 2,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
          trailing: Text(value.toStringAsFixed(2)),
        ),
      ],
    );
  }
}