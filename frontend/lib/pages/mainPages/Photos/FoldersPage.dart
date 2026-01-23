import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Routes/routes.gr.dart';
import '../../../bloc/FoldersBloc/bloc.dart';
import '../../../bloc/FoldersBloc/states.dart';
import '../../../models/Folders/Folder.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const _Buttons(),
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
                      return Center(
                        child: Text(
                          state.error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (state.folders.isEmpty) {
                      return const Center(
                        child: Text('No folders yet'),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.folders.length,
                      itemBuilder: (_, int index) {
                        return _FolderTile(folder: state.folders[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {

  const _FolderTile({required this.folder});
  final Folder folder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.router.push(FolderDetailsRoute(folder: folder));
      },
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.folder_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const Spacer(),
              Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${folder.photosCount} photos',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: const Text('Favourite'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
            label: const Text('Trash'),
          ),
        ),
      ],
    );
  }
}
