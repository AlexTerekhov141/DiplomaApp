import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../Widgets/ResponsiveFrame.dart';
import '../../../../../bloc/PhotosBloc/bloc.dart';
import '../../../../../bloc/PhotosBloc/states.dart';
import '../../../../../bloc/themebloc/bloc.dart';
import '../../../../../bloc/themebloc/states.dart';
import '../../../../../constants/Utils/FolderGridSizeMapper.dart';
import 'GalleryErrorState.dart';
import 'GalleryLoadingState.dart';
import 'GalleryPhotosGrid.dart';
import 'GalleryProccesingCard.dart';


class GalleryView extends StatelessWidget {
  const GalleryView({
    super.key,
    required this.onRefresh,
    required this.onSyncFinished,
    required this.onSyncError,
    required this.onProcessingStateChanged,
  });

  final Future<void> Function() onRefresh;
  final VoidCallback onSyncFinished;
  final ValueChanged<String> onSyncError;
  final ValueChanged<PhotosState> onProcessingStateChanged;

  @override
  Widget build(BuildContext context) {
    return ResponsiveFrame(
      maxWidth: 1200,
      mobilePadding: EdgeInsets.zero,
      desktopPadding: EdgeInsets.zero,
      child: BlocConsumer<PhotosBloc, PhotosState>(
        listenWhen: (PhotosState previous, PhotosState current) {
          final bool syncFinished = previous.isSyncing && !current.isSyncing;
          final bool newSyncError = previous.syncError != current.syncError;
          final bool pendingChanged =
              previous.remotePendingCount != current.remotePendingCount;

          return syncFinished || newSyncError || pendingChanged;
        },
        listener: (BuildContext context, PhotosState state) {
          if (state.syncError != null && state.syncError!.isNotEmpty) {
            onSyncError(state.syncError!);
          } else if (!state.isSyncing && state.uploadedCount > 0) {
            onSyncFinished();
          }

          onProcessingStateChanged(state);
        },
        builder: (BuildContext context, PhotosState state) {
          if (state.isLoading) {
            return const GalleryLoadingState();
          }

          if (state.error != null) {
            return GalleryErrorState(message: state.error!);
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int baseCount = constraints.maxWidth >= 1000
                    ? 6
                    : constraints.maxWidth >= 700
                    ? 4
                    : 3;

                final GalleryGridSize gridSize = context.select(
                      (ThemeBloc bloc) => bloc.state.gridSize,
                );

                final int crossAxisCount = applyFolderGridSize(
                  baseCount,
                  gridSize,
                );

                final int processed = state.remoteProcessedCount;
                final int total = state.remoteTotalCount;
                final int pending = state.remotePendingCount;

                final double progress = total > 0
                    ? (processed / total).clamp(0.0, 1.0)
                    : 0.0;

                final bool showProcessingCard =
                    state.isProcessingStatusLoading || pending > 0;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    /*if (showProcessingCard)
                      SliverToBoxAdapter(
                        child: GalleryProcessingCard(
                          processed: processed,
                          total: total,
                          pending: pending,
                          progress: progress,
                        ),
                      ),*/
                    GalleryPhotosGrid(
                      photos: state.activePhotos,
                      crossAxisCount: crossAxisCount,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}