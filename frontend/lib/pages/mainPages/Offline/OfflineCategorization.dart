import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Routes/routes.gr.dart';
import '../../../bloc/FoldersBloc/foldersbloc.dart';
import '../../../bloc/PhotosBloc/photosbloc.dart';
import '../../../constants/colors.dart';
import 'Widgets/OfflineProcessingActions.dart';
import 'Widgets/OfflineProcessingHeader.dart';
import 'Widgets/OfflineProcessingProgressCard.dart';

@RoutePage()
class OfflineCategorizationPage extends StatefulWidget {
  const OfflineCategorizationPage({super.key});

  @override
  State<OfflineCategorizationPage> createState() =>
      _OfflineCategorizationPageState();
}

class _OfflineCategorizationPageState extends State<OfflineCategorizationPage> {
  bool _returnWhenPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final PhotosState state = context.read<PhotosBloc>().state;
      if (!state.isLocalProcessing && !state.isLocalProcessingPaused) {
        context.read<PhotosBloc>().add(StartLocalProcessingEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhotosBloc, PhotosState>(
      listenWhen: (PhotosState previous, PhotosState current) {
        return previous.isLocalProcessingPaused != current.isLocalProcessingPaused || previous.localProcessingError != current.localProcessingError;
      },
      listener: (BuildContext context, PhotosState state) {
        if (_returnWhenPaused && state.isLocalProcessingPaused) {
          _returnToApp(loadFolders: false);
        }

        final String? error = state.localProcessingError;
        if (error != null && error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
      builder: (BuildContext context, PhotosState state) {
        final int total = state.localTotalCount;
        final int processed = state.localProcessedCount;
        final int pending = state.localPendingCount;
        final double? progress = total > 0 ? (processed / total).clamp(0.0, 1.0) : null;
        final bool isDone = total > 0 && pending == 0 && !state.isLocalProcessing;
        final bool canGoBack = isDone || state.localProcessingError != null || (!state.isLocalProcessing && !state.isLocalProcessingPaused && state.localProcessingMessage != null);

        return Scaffold(
          backgroundColor: Base.c50,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      OfflineProcessingHeader(
                        state: state,
                        isDone: isDone,
                      ),
                      const SizedBox(height: 32),
                      OfflineProcessingProgressCard(
                        processed: processed,
                        total: total,
                        pending: pending,
                        progress: progress,
                        isPaused: state.isLocalProcessingPaused,
                        isDone: isDone,
                      ),
                      const SizedBox(height: 24),
                      OfflineProcessingActions(
                        state: state,
                        canGoBack: canGoBack,
                        onStop: _stopAndReturn,
                        onContinue: () {
                          context
                              .read<PhotosBloc>()
                              .add(ResumeLocalProcessingEvent());
                        },
                        onBack: () => _returnToApp(loadFolders: isDone),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _stopAndReturn() {
    setState(() {
      _returnWhenPaused = true;
    });
    context.read<PhotosBloc>().add(StopLocalProcessingEvent());
  }

  void _returnToApp({required bool loadFolders}) {
    context.read<FoldersBloc>().add(LoadFolders(forceRefresh: true));
    context.router.replaceAll(<PageRouteInfo>[
      AppRoute(initialIndex: loadFolders ? 1 : 0),
    ]);
  }
}
