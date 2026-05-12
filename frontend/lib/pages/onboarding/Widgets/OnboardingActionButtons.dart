import 'package:flutter/material.dart';

class OnboardingActionButtons extends StatelessWidget {
  const OnboardingActionButtons({
    super.key,
    required this.isLastPage,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool isLastPage;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimaryPressed,
              child: Text(
                isLastPage ? 'Create account' : 'Next',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onSecondaryPressed,
          child: Text(
            isLastPage ? 'Log in' : 'Skip',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
