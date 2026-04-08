import 'package:flutter/material.dart';

class OnboardingTopIndicators extends StatelessWidget {
  const OnboardingTopIndicators({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  final int itemCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, (int index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: isActive ? 24 : 10,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF7B7DF6)
                : const Color(0xFFD7DBE8),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}