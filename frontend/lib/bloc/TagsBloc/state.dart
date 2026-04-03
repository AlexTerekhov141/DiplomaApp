import 'package:equatable/equatable.dart';

import '../../models/Photo.dart';

class TagsBlocState extends Equatable {
  const TagsBlocState({
    required this.allPhotosInFolder,
    required this.filteredPhotos,
    required this.availableTags,
    required this.selectedTags,
    required this.searchQuery,
    required this.isLoading,
    this.error,
  });

  factory TagsBlocState.initial() {
    return const TagsBlocState(
      allPhotosInFolder: <Photo>[],
      filteredPhotos: <Photo>[],
      availableTags: <String>[],
      selectedTags: <String>[],
      searchQuery: '',
      isLoading: false,
      error: null,
    );
  }

  final List<Photo> allPhotosInFolder;
  final List<Photo> filteredPhotos;
  final List<String> availableTags;
  final List<String> selectedTags;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  TagsBlocState copyWith({
    List<Photo>? allPhotosInFolder,
    List<Photo>? filteredPhotos,
    List<String>? availableTags,
    List<String>? selectedTags,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TagsBlocState(
      allPhotosInFolder: allPhotosInFolder ?? this.allPhotosInFolder,
      filteredPhotos: filteredPhotos ?? this.filteredPhotos,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[allPhotosInFolder, filteredPhotos, availableTags, selectedTags, searchQuery, isLoading, error,];
}