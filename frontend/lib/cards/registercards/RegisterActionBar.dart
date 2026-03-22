import 'package:flutter/material.dart';

class RegisterActionBar extends StatelessWidget {
  const RegisterActionBar({
    super.key,
    required this.currentStep,
    required this.isLoading,
    required this.onBack,
    required this.onContinue,
  });

  final int currentStep;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = currentStep == 1;

    return Row(
      children: <Widget>[
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: isLoading ? null : onContinue,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
                : Text(isLastStep ? 'Create account' : 'Continue'),
          ),
        ),
      ],
    );
  }
}