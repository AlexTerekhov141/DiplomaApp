import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomBar extends StatelessWidget {

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      items: <SalomonBottomBarItem>[
        SalomonBottomBarItem(
          icon: const Icon(Icons.image),
          title: const Text('Gallery'),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.folder_copy),
          title: const Text('Folders'),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.grid_view_rounded),
          title: const Text('Features'),
        ),
      ],
    );
  }
}
