import 'package:categorize_app/models/SlideData.dart';
import 'package:flutter/material.dart';


class OnboardingSlideContent extends StatelessWidget {
  const OnboardingSlideContent({
    super.key,
    required this.slide,
  });

  final SlideData slide;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
  }
}