import 'package:flutter/material.dart';

class FolderEmptyState extends StatelessWidget {
  const FolderEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No photos match your filters'),
    );
  }
}