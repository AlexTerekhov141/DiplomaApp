import 'package:flutter/material.dart';

class FoldersEmptyState extends StatelessWidget {
  const FoldersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        SizedBox(height: 120),
        Center(
          child: Text('No folders yet'),
        ),
      ],
    );
  }
}