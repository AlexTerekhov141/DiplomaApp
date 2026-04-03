import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/tagsbloc/bloc.dart';
import 'package:categorize_app/bloc/tagsbloc/event.dart';
import 'package:categorize_app/bloc/tagsbloc/state.dart';
import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:categorize_app/bloc/themebloc/states.dart';
import 'package:categorize_app/models/Folders/Folder.dart';
import 'package:categorize_app/models/Photo.dart';
import 'package:categorize_app/pages/mainPages/Photos/Photo.dart';
import 'package:categorize_app/repository/PhotosRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class FolderDetailsPage extends StatelessWidget {
  const FolderDetailsPage({super.key, required this.folder});

  final Folder folder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TagsBloc>(
      create: (_) => TagsBloc(
        photosRepository: GetIt.I<PhotosRepository>(),
      )..add(LoadFolderPhotos(folderId: folder.id)),
      child: _FolderDetailsView(folder: folder),
    );
  }
}

class _FolderDetailsView extends StatelessWidget {
  const _FolderDetailsView({required this.folder});

  final Folder folder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folder.name)),
      body: ResponsiveFrame(
        maxWidth: 1000,
        child: BlocBuilder<TagsBloc, TagsBlocState>(
          builder: (BuildContext context, TagsBlocState state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            final List<Photo> photos = state.filteredPhotos;

            return LayoutBuilder(
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

                final String search = state.searchQuery.toLowerCase().trim();

                final List<String> visibleTags = state.availableTags.where((String tag) {
                  if (search.isEmpty) return true;
                  return tag.toLowerCase().contains(search);
                }).toList();

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: TextField(
                        onChanged: (String value) {
                          context.read<TagsBloc>().add(
                            SearchQueryChanged(query: value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by tag',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: (state.searchQuery.isNotEmpty ||
                              state.selectedTags.isNotEmpty)
                              ? IconButton(
                            onPressed: () {
                              context.read<TagsBloc>().add(
                                 ClearFilters(),
                              );
                            },
                            icon: const Icon(Icons.clear),
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    if (state.selectedTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.selectedTags.map((String tag) {
                              return InputChip(
                                label: Text(tag),
                                selected: true,
                                onSelected: (_) {
                                  context.read<TagsBloc>().add(
                                    TagUnselected(tag: tag),
                                  );
                                },
                                onDeleted: () {
                                  context.read<TagsBloc>().add(
                                    TagUnselected(tag: tag),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    if (visibleTags.isNotEmpty)
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: visibleTags.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, int index) {
                            final String tag = visibleTags[index];
                            final bool isSelected =
                            state.selectedTags.contains(tag);

                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (_) {
                                context.read<TagsBloc>().add(
                                  isSelected
                                      ? TagUnselected(tag: tag)
                                      : TagSelected(tag: tag),
                                );
                              },
                            );
                          },
                        ),
                      ),

                    Expanded(
                      child: photos.isEmpty
                          ? const Center(
                        child: Text('No photos match your filters'),
                      )
                          : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: photos.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (_, int index) {
                          final Photo photo = photos[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      NetworkPhotoViewerPage(photo: photo),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photo.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const ColoredBox(
                                  color: Colors.black12,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
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