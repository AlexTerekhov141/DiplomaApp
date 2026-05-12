import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  String? _lastShownSyncError;

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshGallery() async {
    final PhotosBloc photosBloc = context.read<PhotosBloc>();
    photosBloc.add(PhotosLoadEvent());

    await photosBloc.stream.firstWhere(
      (PhotosState state) => !state.isLoading,
    );
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
  }

  void _handleProcessingState(PhotosState _) {}

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
