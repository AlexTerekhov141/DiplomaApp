import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../Widgets/ResponsiveFrame.dart';
import '../../../../../bloc/PhotoRoastBloc/bloc.dart';
import '../../../../../bloc/PhotoRoastBloc/event.dart';
import '../../../../../bloc/PhotoRoastBloc/state.dart';
import 'PhotoRoastIssuesSection.dart';
import 'PhotoRoastPreview.dart';
import 'PhotoRoastScoreCard.dart';
import 'PhotoRoastToolBar.dart';


class PhotoRoastView extends StatelessWidget {
  const PhotoRoastView({
    super.key,
    required this.showIssues,
    required this.onToggleIssues,
  });

  final bool showIssues;
  final VoidCallback onToggleIssues;

  @override
  Widget build(BuildContext context) {
    return ResponsiveFrame(
      maxWidth: 1100,
      child: BlocConsumer<PhotoRoastBloc, PhotoRoastState>(
        listenWhen: (PhotoRoastState prev, PhotoRoastState curr) =>
        prev.error != curr.error && curr.error != null,
        listener: (BuildContext context, PhotoRoastState state) {
          final String message = state.error ?? 'Unknown error';

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message)),
            );

          context.read<PhotoRoastBloc>().add(
            const PhotoRoastErrorCleared(),
          );
        },
        builder: (BuildContext context, PhotoRoastState state) {
          if (state.isAnalyzing) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: <Widget>[
              PhotoRoastToolbar(
                onImagePicked: (Uint8List bytes) {
                  context.read<PhotoRoastBloc>().add(
                    PhotoRoastImageLoaded(bytes),
                  );
                },
                onAnalyzePressed: () {
                  context.read<PhotoRoastBloc>().add(
                    const PhotoRoastAnalyzeRequested(),
                  );
                },
                onResetPressed: () {
                  context.read<PhotoRoastBloc>().add(
                    const PhotoRoastResetRequested(),
                  );
                },
              ),
              PhotoRoastPreview(
                imageBytes: state.imageBytes,
              ),
              PhotoRoastScoreCard(
                score: state.score,
              ),
              PhotoRoastIssuesSection(
                showIssues: showIssues,
                issues: state.issues,
                onToggle: onToggleIssues,
              ),
            ],
          );
        },
      ),
    );
  }
}