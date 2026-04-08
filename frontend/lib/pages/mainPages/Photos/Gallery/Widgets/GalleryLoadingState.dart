import 'package:flutter/material.dart';

class GalleryLoadingState extends StatelessWidget {
  const GalleryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}