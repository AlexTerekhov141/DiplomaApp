import 'package:flutter/material.dart';

class EnhanceActionButton extends StatelessWidget {
  const EnhanceActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}