import 'package:flutter/material.dart';

class ButtonEnchance extends StatelessWidget {
  const ButtonEnchance(this.text, this.func);

  final String text;
  final VoidCallback func;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: func, child: Text(text));
  }
}