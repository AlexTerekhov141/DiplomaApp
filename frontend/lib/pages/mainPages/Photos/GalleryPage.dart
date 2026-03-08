import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/FoldersBloc/bloc.dart';
import 'package:categorize_app/bloc/FoldersBloc/events.dart';
import 'package:categorize_app/bloc/PhotosBloc/bloc.dart';
import 'package:categorize_app/bloc/PhotosBloc/events.dart';
import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:categorize_app/bloc/themebloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../bloc/PhotosBloc/states.dart';

@RoutePage()
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with AutomaticKeepAliveClientMixin {
  Timer? _processingPollTimer;
  String? _lastShownSyncError;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _processingPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshGallery() async {
    final PhotosBloc photosBloc = context.read<PhotosBloc>();
    photosBloc.add(PhotosLoadEvent());
    await photosBloc.stream.firstWhere(
      (PhotosState state) => !state.isLoading && !state.isSyncing,
    );
    if (!mounted) {
      return;
    }
    context.read<FoldersBloc>().add(LoadFolders(forceRefresh: true));
  }

  void _startProcessingPolling() {
    if (_processingPollTimer != null) {
      return;
    }
    _processingPollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) {
        return;
      }
      final PhotosBloc photosBloc = context.read<PhotosBloc>();
      photosBloc.add(PhotosRefreshProcessingStatusEvent());
      context.read<FoldersBloc>().add(LoadFolders(forceRefresh: true));
    });
  }

  void _stopProcessingPolling() {
    _processingPollTimer?.cancel();
    _processingPollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ResponsiveFrame(
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
            if (state.syncError != null &&
                state.syncError!.isNotEmpty &&
                state.syncError != _lastShownSyncError) {
              _lastShownSyncError = state.syncError;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload error: ${state.syncError}')),
              );
            } else if (!state.isSyncing && state.uploadedCount > 0) {
              _lastShownSyncError = null;
              context.read<FoldersBloc>().add(LoadFolders(forceRefresh: true));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Uploaded photos: ${state.uploadedCount}')),
              );
            }

            final bool allUploaded =
                state.photos.isNotEmpty &&
                state.remoteTotalCount >= state.photos.length;

            if (state.remotePendingCount > 0 && !allUploaded) {
              _startProcessingPolling();
            } else {
              _stopProcessingPolling();
            }
          },
          builder: (BuildContext context, PhotosState state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            return RefreshIndicator(
              onRefresh: _refreshGallery,
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
                  final int crossAxisCount = _applyGridSize(baseCount, gridSize);

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
                      if (showProcessingCard)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Server categorization',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Categorized: $processed / $total   Pending: $pending',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(value: progress),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, int index) {
                            return GestureDetector(
                              onTap: () {
                                context.router.push(
                                  PhotoViewerRoute(photo: state.photos[index]),
                                );
                              },
                              child: AssetEntityImage(
                                state.photos[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          childCount: state.photos.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

int _applyGridSize(int baseCount, GalleryGridSize gridSize) {
  switch (gridSize) {
    case GalleryGridSize.small:
      return baseCount + 1;
    case GalleryGridSize.medium:
      return baseCount;
    case GalleryGridSize.large:
      return baseCount > 2 ? baseCount - 1 : 2;
  }
}
