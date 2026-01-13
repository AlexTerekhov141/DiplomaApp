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
    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: <SalomonBottomBarItem>[
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Home'),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.folder),
          title: const Text('Categorize'),
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.chat),
          title: const Text('Chat'),
        ),
      ],
    );
  }
}
