import 'package:flutter/material.dart';

import '../../../../bloc/PhotosBloc/photosbloc.dart';

class OfflineProcessingActions extends StatelessWidget {
  const OfflineProcessingActions({
    super.key,
    required this.state,
    required this.canGoBack,
    required this.onStop,
    required this.onContinue,
    required this.onBack,
  });

  final PhotosState state;
  final bool canGoBack;
  final VoidCallback onStop;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (state.isLocalProcessingPaused) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBack,
            child: const Text('Back to app'),
          ),
        ],
      );
    }

    if (canGoBack) {
      return ElevatedButton(
        onPressed: onBack,
        child: const Text('Back to app'),
      );
    }

    return OutlinedButton.icon(
      onPressed: state.isLocalProcessing ? onStop : null,
      icon: const Icon(Icons.stop_circle_outlined),
      label: const Text('Stop and return'),
    );
  }
}
