import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../Widgets/ResponsiveFrame.dart';
import '../../../../../bloc/EnchanceBloc/bloc.dart';
import '../../../../../bloc/EnchanceBloc/event.dart';
import '../../../../../bloc/EnchanceBloc/state.dart';
import '../../../../../models/EnchanceModel.dart';
import 'EnchancePreview.dart';
import 'EnchanceSlidersCard.dart';
import 'EnchanceToolbar.dart';


class EnhanceView extends StatelessWidget {
  const EnhanceView({
    super.key,
    required this.model,
    required this.onDraftChanged,
  });

  final EnhanceModel model;
  final ValueChanged<EnhanceModel> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return ResponsiveFrame(
      maxWidth: 1100,
      child: BlocConsumer<EnchanceBloc, EnchanceState>(
        listenWhen: (EnchanceState prev, EnchanceState curr) =>
        prev.error != curr.error && curr.error != null,
        listener: (BuildContext context, EnchanceState state) {
          final String message = state.error ?? 'Unknown error';

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message)),
            );

          context.read<EnchanceBloc>().add(
            const EnchanceErrorCleared(),
          );
        },
        builder: (BuildContext context, EnchanceState state) {
          if (state.isProcessing) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: <Widget>[
              EnhanceToolbar(
                onImagePicked: (Uint8List bytes) {
                  context.read<EnchanceBloc>().add(
                    EnchanceImageLoaded(bytes),
                  );
                },
                onAutoPressed: () {
                  context.read<EnchanceBloc>().add(
                    const EnchanceAutoApplied(),
                  );
                },
                onResetPressed: () {
                  context.read<EnchanceBloc>().add(
                    const EnchanceResetRequested(),
                  );
                },
                onSaveCopyPressed: () {
                  context.read<EnchanceBloc>().add(
                    const EnchanceSaveCopyRequested(),
                  );
                },
              ),
              EnhancePreview(
                editedBytes: state.editedBytes,
              ),
              EnhanceSlidersCard(
                state: state,
                model: model,
                onDraftChanged: onDraftChanged,
                onEvent: (EnchanceEvent event) {
                  context.read<EnchanceBloc>().add(event);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}