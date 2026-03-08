import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Routes/routes.gr.dart';
import '../../../bloc/FoldersBloc/bloc.dart';
import '../../../bloc/FoldersBloc/events.dart';
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
            const _Buttons(),
            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<FoldersBloc, FoldersState>(
                builder: (BuildContext context, FoldersState state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null) {
                    return Center(
                      child: Text(
                        state.error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshFolders,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            if (state.folders.isEmpty) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const <Widget>[
                                  SizedBox(height: 120),
                                  Center(child: Text('No folders yet')),
                                ],
                              );
                            }

                            final int crossAxisCount =
                                constraints.maxWidth >= 1000
                                ? 4
                                : constraints.maxWidth >= 700
                                ? 3
                                : 2;
                            return GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
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

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.folder});
  final Folder folder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const BorderRadius radius = BorderRadius.all(Radius.circular(16));

    return InkWell(
      borderRadius: radius,
      onTap: () {
        context.router.push(FolderDetailsRoute(folder: folder));
      },
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: radius,
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _FolderPreview(previewUrls: folder.previewUrls),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0x00000000),
                        Color(0xB3000000),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${folder.photosCount} photos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderPreview extends StatelessWidget {
  const _FolderPreview({required this.previewUrls});

  final List<String> previewUrls;

  @override
  Widget build(BuildContext context) {
    if (previewUrls.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.folder_rounded,
          size: 36,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final List<String> urls = previewUrls.take(4).toList();
    final int count = urls.length;

    if (count == 1) {
      return _PreviewImage(url: urls[0]);
    }
    if (count == 2) {
      return Row(
        children: <Widget>[
          Expanded(child: _PreviewImage(url: urls[0])),
          const SizedBox(width: 2),
          Expanded(child: _PreviewImage(url: urls[1])),
        ],
      );
    }
    if (count == 3) {
      return Row(
        children: <Widget>[
          Expanded(child: _PreviewImage(url: urls[0])),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(child: _PreviewImage(url: urls[1])),
                const SizedBox(height: 2),
                Expanded(child: _PreviewImage(url: urls[2])),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: _PreviewImage(url: urls[0])),
              const SizedBox(width: 2),
              Expanded(child: _PreviewImage(url: urls[1])),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: _PreviewImage(url: urls[2])),
              const SizedBox(width: 2),
              Expanded(child: _PreviewImage(url: urls[3])),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, size: 16),
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
