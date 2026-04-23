import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/FoldersBloc/bloc.dart';
import '../../../../bloc/FoldersBloc/events.dart';
import '../../../../bloc/PhotosBloc/bloc.dart';
import '../../../../bloc/PhotosBloc/events.dart';
import '../../../../bloc/PhotosBloc/states.dart';
import 'Widgets/GalleryView.dart';

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

    context.read<FoldersBloc>().add(
      LoadFolders(forceRefresh: true),
    );
  }

  void _startProcessingPolling() {
    if (_processingPollTimer != null) {
      return;
    }

    _processingPollTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!mounted) {
          return;
        }

        context.read<PhotosBloc>().add(
          PhotosRefreshProcessingStatusEvent(),
        );

        context.read<FoldersBloc>().add(
          LoadFolders(forceRefresh: true),
        );
      },
    );
  }

  void _stopProcessingPolling() {
    _processingPollTimer?.cancel();
    _processingPollTimer = null;
  }

  void _handleSyncError(String error) {
    if (error == _lastShownSyncError) {
      return;
    }

    _lastShownSyncError = error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload error: $error'),
      ),
    );
  }

  void _handleSyncFinished() {
    _lastShownSyncError = null;

    context.read<FoldersBloc>().add(
      LoadFolders(forceRefresh: true),
    );

    final PhotosState state = context.read<PhotosBloc>().state;
    /*if (state.uploadedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploaded photos: ${state.uploadedCount}'),
        ),
      );
    }*/
  }

  void _handleProcessingState(PhotosState state) {
    final bool allUploaded =
        state.photos.isNotEmpty &&
            state.remoteTotalCount >= state.photos.length;

    if (state.remotePendingCount > 0 && !allUploaded) {
      _startProcessingPolling();
    } else {
      _stopProcessingPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: GalleryView(
        onRefresh: _refreshGallery,
        onSyncFinished: _handleSyncFinished,
        onSyncError: _handleSyncError,
        onProcessingStateChanged: _handleProcessingState,
      ),
    );
  }
}