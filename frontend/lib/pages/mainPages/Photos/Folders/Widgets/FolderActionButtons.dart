import 'package:flutter/material.dart';

class FoldersActionButtons extends StatelessWidget {
  const FoldersActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: const Text('Favourite'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            label: const Text('Trash'),
          ),
        ),
      ],
    );
  }
}