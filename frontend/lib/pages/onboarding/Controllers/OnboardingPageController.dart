import 'package:flutter/material.dart';

class OnboardingPageController {
  OnboardingPageController() : pageController = PageController();

  final PageController pageController;
  int currentIndex = 0;

  bool isLastPage(int slidesCount) => currentIndex == slidesCount - 1;

  void onPageChanged(int index, VoidCallback notify) {
    currentIndex = index;
    notify();
  }

  Future<void> nextPage({
    required int slidesCount,
    required VoidCallback onDone,
  }) async {
    if (currentIndex == slidesCount - 1) {
      onDone();
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void dispose() {
    pageController.dispose();
  }
}