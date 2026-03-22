import 'package:flutter/material.dart';

import '../../models/SlideData.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({
    super.key,
    required this.onDone,
    required this.onRegister,
  });

  final VoidCallback onDone;
  final VoidCallback onRegister;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<SlideData> _slides = <SlideData>[
    SlideData(
      title: 'Smart photo organization',
      subtitle:
      'Group photos automatically so the gallery stays clear without manual sorting.',
      icon: Icons.auto_awesome_rounded,
      image: Image(image: AssetImage('assets/onboarding/1.jpg')),
    ),
    SlideData(
      title: 'AI-based grouping',
      subtitle:
      'Categories and tags are generated in background while you continue using the app.',
      icon: Icons.hub_rounded,
      image: Image(image: AssetImage('assets/onboarding/2.jpg')),
    ),
    SlideData(
      title: 'Cleaner gallery',
      subtitle:
      'Start managing your photos with folders that stay updated automatically.',
      icon: Icons.photo_library_rounded,
      image: Image(image: AssetImage('assets/onboarding/3.jpg')),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex == _slides.length - 1) {
      widget.onDone();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            _TopIndicators(
              itemCount: _slides.length,
              currentIndex: _currentIndex,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (int index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (BuildContext context, int index) {
                  final SlideData slide = _slides[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Column(
                      children: <Widget>[
                        const Spacer(),
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: slide.image,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: const Color(0xFF7B8094),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLastPage ? widget.onRegister : _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7B7DF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLastPage ? 'Create account' : 'Next',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: isLastPage ? widget.onDone : widget.onDone,
              child: Text(
                isLastPage ? 'Log in' : 'Skip',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7B8094),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TopIndicators extends StatelessWidget {
  const _TopIndicators({
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