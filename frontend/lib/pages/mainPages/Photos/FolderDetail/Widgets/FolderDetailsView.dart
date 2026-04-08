import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/tagsbloc/bloc.dart';
import 'package:categorize_app/bloc/tagsbloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/themebloc/bloc.dart';
import '../../../../../bloc/themebloc/states.dart';
import '../../../../../constants/Utils/FolderGridSizeMapper.dart';
import '../../../../../models/Folders/Folder.dart';
import '../../../../../models/Photo.dart';
import 'FolderEmptyState.dart';
import 'FolderErrorState.dart';
import 'FolderPhotosGrid.dart';
import 'FolderSearchBar.dart';
import 'SelectedTagsWrap.dart';
import 'TagsFilterList.dart';


class FolderDetailsView extends StatelessWidget {
  const FolderDetailsView({
    super.key,
    required this.folder,
  });

  final Folder folder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
      ),
      body: ResponsiveFrame(
        maxWidth: 1000,
        child: BlocBuilder<TagsBloc, TagsBlocState>(
          builder: (BuildContext context, TagsBlocState state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null) {
              return FolderErrorState(message: state.error!);
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

                final int crossAxisCount = applyFolderGridSize(
                  baseCount,
                  gridSize,
                );

                final String search = state.searchQuery.toLowerCase().trim();

                final List<String> visibleTags = state.availableTags
                    .where((String tag) {
                  if (search.isEmpty) {
                    return true;
                  }
                  return tag.toLowerCase().contains(search);
                })
                    .toList();

                return Column(
                  children: <Widget>[
                    FolderSearchBar(
                      searchQuery: state.searchQuery,
                      hasFilters: state.searchQuery.isNotEmpty ||
                          state.selectedTags.isNotEmpty,
                    ),
                    if (state.selectedTags.isNotEmpty)
                      SelectedTagsWrap(
                        selectedTags: state.selectedTags,
                      ),
                    if (visibleTags.isNotEmpty)
                      TagsFilterList(
                        visibleTags: visibleTags,
                        selectedTags: state.selectedTags,
                      ),
                    Expanded(
                      child: photos.isEmpty
                          ? const FolderEmptyState()
                          : FolderPhotosGrid(
                        photos: photos,
                        crossAxisCount: crossAxisCount,
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