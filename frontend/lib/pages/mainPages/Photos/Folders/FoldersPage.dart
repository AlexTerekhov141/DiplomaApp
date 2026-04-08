import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import '../../../../bloc/FoldersBloc/bloc.dart';
import '../../../../bloc/FoldersBloc/events.dart';
import '../../../../bloc/FoldersBloc/states.dart';
import 'Widgets/FolderActionButtons.dart';
import 'Widgets/FoldersEmptyState.dart';
import 'Widgets/FoldersErrorState.dart';
import 'Widgets/FoldersGrid.dart';

@RoutePage()
class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshFolders() async {
    final FoldersBloc foldersBloc = context.read<FoldersBloc>();
    foldersBloc.add(LoadFolders(forceRefresh: true));

    await foldersBloc.stream.firstWhere(
          (FoldersState state) => !state.isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: ResponsiveFrame(
        maxWidth: 1100,
        child: Column(
          children: <Widget>[
            const FoldersActionButtons(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<FoldersBloc, FoldersState>(
                builder: (BuildContext context, FoldersState state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.error != null) {
                    return FoldersErrorState(message: state.error!);
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshFolders,
                    child: LayoutBuilder(
                      builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                          ) {
                        if (state.folders.isEmpty) {
                          return const FoldersEmptyState();
                        }

                        final int crossAxisCount = constraints.maxWidth >= 1000
                            ? 4
                            : constraints.maxWidth >= 700
                            ? 3
                            : 2;

                        return FoldersGrid(
                          folders: state.folders,
                          crossAxisCount: crossAxisCount,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}