import 'package:flutter/material.dart';

class FolderErrorState extends StatelessWidget {
  const FolderErrorState({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}