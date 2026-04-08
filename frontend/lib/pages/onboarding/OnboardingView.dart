import 'package:flutter/material.dart';

import 'Controllers/OnboardingPageController.dart';
import 'Widgets/OnboardingActionButtons.dart';
import 'Widgets/OnboardingSlideContent.dart';
import 'Widgets/OnboardingTopIndicators.dart';
import 'data/OnboardingSlides.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.onDone,
    required this.onRegister,
  });

  final VoidCallback onDone;
  final VoidCallback onRegister;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingPageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _controller.isLastPage(onboardingSlides.length);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            OnboardingTopIndicators(
              itemCount: onboardingSlides.length,
              currentIndex: _controller.currentIndex,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller.pageController,
                itemCount: onboardingSlides.length,
                onPageChanged: (int index) {
                  _controller.onPageChanged(index, _rebuild);
                },
                itemBuilder: (BuildContext context, int index) {
                  return OnboardingSlideContent(
                    slide: onboardingSlides[index],
                  );
                },
              ),
            ),
            OnboardingActionButtons(
              isLastPage: isLastPage,
              onPrimaryPressed: () async {
                if (isLastPage) {
                  widget.onRegister();
                  return;
                }

                await _controller.nextPage(
                  slidesCount: onboardingSlides.length,
                  onDone: widget.onDone,
                );
              },
              onSecondaryPressed: widget.onDone,
            ),
          ],
        ),
      ),
    );
  }
}