import 'package:categorize_app/bloc/tagsbloc/event.dart';
import 'package:categorize_app/bloc/tagsbloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/Photo.dart';
import '../../repository/PhotosRepository/PhotosRepository.dart';


class TagsBloc extends Bloc<TagsBlocEvent, TagsBlocState> {
  TagsBloc({required PhotosRepository photosRepository})
      : _photosRepository = photosRepository,
        super(TagsBlocState.initial()) {
    on<LoadFolderPhotos>(_onLoadFolderPhotos);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<TagSelected>(_onTagSelected);
    on<TagUnselected>(_onTagUnselected);
    on<ClearFilters>(_onClearFilters);
  }

  final PhotosRepository _photosRepository;

  Future<void> _onLoadFolderPhotos(
      LoadFolderPhotos event,
      Emitter<TagsBlocState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final List<Map<String, dynamic>> rawPhotos =
      await _photosRepository.getPhotos(isProcessed: true);

      final bool isUncategorized = event.folderId == 'uncategorized';

      final List<Photo> folderPhotos = rawPhotos
          .map(Photo.fromJson)
          .where((Photo photo) {
        if (isUncategorized) {
          return photo.categoryId == null || photo.categoryId!.isEmpty;
        }
        return photo.categoryId == event.folderId;
      })
          .toList();

      final List<String> availableTags = folderPhotos
          .expand((Photo photo) => photo.tags)
          .map((String tag) => tag.trim())
          .where((String tag) => tag.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      emit(
        state.copyWith(
          allPhotosInFolder: folderPhotos,
          filteredPhotos: folderPhotos,
          availableTags: availableTags,
          selectedTags: <String>[],
          searchQuery: '',
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<TagsBlocState> emit,
      ) {
    final String query = event.query.trim();

    final List<Photo> filteredPhotos = _applyFilters(
      allPhotos: state.allPhotosInFolder,
      selectedTags: state.selectedTags,
      searchQuery: query,
    );

    emit(
      state.copyWith(
        searchQuery: query,
        filteredPhotos: filteredPhotos,
        clearError: true,
      ),
    );
  }

  void _onTagSelected(
      TagSelected event,
      Emitter<TagsBlocState> emit,
      ) {
    if (state.selectedTags.contains(event.tag)) {
      return;
    }

    final List<String> updatedSelectedTags = <String>[
      ...state.selectedTags,
      event.tag,
    ];

    final List<Photo> filteredPhotos = _applyFilters(
      allPhotos: state.allPhotosInFolder,
      selectedTags: updatedSelectedTags,
      searchQuery: state.searchQuery,
    );

    emit(
      state.copyWith(
        selectedTags: updatedSelectedTags,
        filteredPhotos: filteredPhotos,
        clearError: true,
      ),
    );
  }

  void _onTagUnselected(
      TagUnselected event,
      Emitter<TagsBlocState> emit,
      ) {
    final List<String> updatedSelectedTags = state.selectedTags
        .where((String tag) => tag != event.tag)
        .toList();

    final List<Photo> filteredPhotos = _applyFilters(
      allPhotos: state.allPhotosInFolder,
      selectedTags: updatedSelectedTags,
      searchQuery: state.searchQuery,
    );

    emit(
      state.copyWith(
        selectedTags: updatedSelectedTags,
        filteredPhotos: filteredPhotos,
        clearError: true,
      ),
    );
  }

  void _onClearFilters(
      ClearFilters event,
      Emitter<TagsBlocState> emit,
      ) {
    emit(
      state.copyWith(
        selectedTags: <String>[],
        searchQuery: '',
        filteredPhotos: state.allPhotosInFolder,
        clearError: true,
      ),
    );
  }

  List<Photo> _applyFilters({
    required List<Photo> allPhotos,
    required List<String> selectedTags,
    required String searchQuery,
  }) {
    return allPhotos.where((Photo photo) {
      final List<String> normalizedPhotoTags = photo.tags
          .map((String tag) => tag.toLowerCase().trim())
          .toList();

      final String normalizedQuery = searchQuery.toLowerCase().trim();

      final bool matchesSearch = normalizedQuery.isEmpty ||
          normalizedPhotoTags.any(
                (String tag) => tag.contains(normalizedQuery),
          );

      final bool matchesSelectedTags = selectedTags.isEmpty ||
          selectedTags.every(
                (String selectedTag) =>
                normalizedPhotoTags.contains(selectedTag.toLowerCase().trim()),
          );

      return matchesSearch && matchesSelectedTags;
    }).toList();
  }
}