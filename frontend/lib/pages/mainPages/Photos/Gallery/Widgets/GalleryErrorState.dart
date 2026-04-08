import 'package:flutter/material.dart';

class GalleryErrorState extends StatelessWidget {
  const GalleryErrorState({
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