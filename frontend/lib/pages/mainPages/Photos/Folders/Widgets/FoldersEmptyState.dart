import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../bloc/FoldersBloc/foldersbloc.dart';
import '../../../../../bloc/PhotosBloc/photosbloc.dart';
import '../../../../../repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';

class FoldersEmptyState extends StatefulWidget {
  const FoldersEmptyState({super.key});

  @override
  State<FoldersEmptyState> createState() => _FoldersEmptyStateState();
}

class _FoldersEmptyStateState extends State<FoldersEmptyState> {
  static const int _maxFolderPollAttempts = 20;
  bool _isCategorizing = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotosBloc, PhotosState>(
      builder: (BuildContext context, PhotosState photosState) {
        return BlocBuilder<FoldersBloc, FoldersState>(
          builder: (BuildContext context, FoldersState foldersState) {
            final bool isBusy =
                _isCategorizing ||
                photosState.isLoading ||
                photosState.isSyncing ||
                foldersState.isLoading;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: isBusy ? null : () => _categorize(context),
                        icon: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_buttonText(photosState, foldersState)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusText(photosState, foldersState),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _categorize(BuildContext context) async {
    final bool isOfflineMode =
        await GetIt.I<ProccessingRouterRepository>().isOfflineMode();
    if (isOfflineMode) {
      if (!mounted) {
        return;
      }
      context.router.replaceAll(<PageRouteInfo>[
        const OfflineCategorizationRoute(),
      ]);
      return;
    }

    setState(() {
      _isCategorizing = true;
    });

    final PhotosBloc photosBloc = context.read<PhotosBloc>();
    final FoldersBloc foldersBloc = context.read<FoldersBloc>();

    try {
      if (photosBloc.state.photos.isNotEmpty) {
        photosBloc.add(PhotosSyncToServerEvent(photosBloc.state.photos));

        await photosBloc.stream.firstWhere(
          (PhotosState state) => !state.isSyncing,
        );

        if (!mounted) {
          return;
        }

        await _loadFoldersUntilReady(photosBloc, foldersBloc);
        return;
      }

      photosBloc.add(PhotosLoadEvent());

      await photosBloc.stream.firstWhere(
        (PhotosState state) => !state.isLoading,
      );

      if (!mounted) {
        return;
      }

      if (photosBloc.state.photos.isNotEmpty) {
        photosBloc.add(PhotosSyncToServerEvent(photosBloc.state.photos));

        await photosBloc.stream.firstWhere(
          (PhotosState state) => !state.isSyncing,
        );

        if (!mounted) {
          return;
        }

        await _loadFoldersUntilReady(photosBloc, foldersBloc);
        return;
      }

      await _loadFoldersOnce(foldersBloc);
    } finally {
      if (mounted) {
        setState(() {
          _isCategorizing = false;
        });
      }
    }
  }

  Future<void> _loadFoldersOnce(FoldersBloc foldersBloc) async {
    foldersBloc.add(LoadFolders(forceRefresh: true));

    await foldersBloc.stream.firstWhere(
      (FoldersState state) => !state.isLoading,
    );
  }

  Future<void> _loadFoldersUntilReady(
    PhotosBloc photosBloc,
    FoldersBloc foldersBloc,
  ) async {
    for (int attempt = 0; attempt < _maxFolderPollAttempts; attempt++) {
      await _loadFoldersOnce(foldersBloc);

      if (!mounted ||
          foldersBloc.state.folders.isNotEmpty ||
          foldersBloc.state.error != null) {
        return;
      }

      photosBloc.add(PhotosRefreshProcessingStatusEvent());

      await photosBloc.stream.firstWhere(
        (PhotosState state) => !state.isProcessingStatusLoading,
      );

      if (!mounted ||
          photosBloc.state.syncError != null ||
          (photosBloc.state.remotePendingCount == 0 &&
              photosBloc.state.remoteTotalCount > 0)) {
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  String _buttonText(PhotosState photosState, FoldersState foldersState) {
    if (_isCategorizing) {
      return 'Categorizing...';
    }
    if (photosState.isLoading) {
      return 'Loading gallery...';
    }
    if (photosState.isSyncing) {
      return 'Categorizing...';
    }
    if (foldersState.isLoading) {
      return 'Loading folders...';
    }
    return 'Categorize';
  }

  String _statusText(PhotosState photosState, FoldersState foldersState) {
    if (_isCategorizing) {
      if (photosState.remoteTotalCount > 0) {
        return 'Processed ${photosState.remoteProcessedCount} of '
            '${photosState.remoteTotalCount} photos.';
      }
      return 'Categorization is running. Folders will appear automatically.';
    }
    if (photosState.isLoading) {
      return 'Looking for photos on this device.';
    }
    if (photosState.isSyncing) {
      return 'Photos are being sent for categorization. Please wait.';
    }
    if (foldersState.isLoading) {
      return 'Loading categorized folders.';
    }
    if (photosState.syncError != null) {
      return 'Could not categorize photos: ${photosState.syncError}';
    }
    return 'Press the button to send photos and load folders.';
  }
}
