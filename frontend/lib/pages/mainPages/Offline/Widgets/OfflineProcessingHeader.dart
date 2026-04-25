import 'package:flutter/material.dart';

import '../../../../bloc/PhotosBloc/photosbloc.dart';

class OfflineProcessingHeader extends StatelessWidget {
  const OfflineProcessingHeader({
    super.key,
    required this.state,
    required this.isDone,
  });

  final PhotosState state;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Icon(
          Icons.offline_bolt_outlined,
          size: 56,
        ),
        const SizedBox(height: 24),
        Text(
          isDone ? 'Local categorization completed' : 'Local processing',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _statusText(state),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
        ),
      ],
    );
  }

  String _statusText(PhotosState state) {
    if (state.localProcessingError != null) {
      return 'Something went wrong. You can go back and try again later.';
    }
    if (state.isLocalProcessingPaused) {
      return 'Processing is paused. Continue here or return to the app.';
    }
    if (state.isLocalProcessing) {
      return 'Keep this screen open for faster categorization. You can turn off the screen, but processing may slow down in the background.';
    }
    if (state.localPendingCount == 0 && state.localTotalCount > 0) {
      return 'You can return to your folders and work with them.';
    }
    if (state.localProcessingMessage != null) {
      return state.localProcessingMessage!;
    }
    return 'Preparing local photo processing...';
  }
}
