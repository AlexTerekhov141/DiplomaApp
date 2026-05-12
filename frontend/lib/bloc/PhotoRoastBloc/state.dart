import 'package:equatable/equatable.dart';

import '../../models/PhotoRoastModels/QualityPhotoGroup.dart';

class PhotoRoastState extends Equatable {
  const PhotoRoastState({
    required this.isLoading,
    required this.groups,
    this.error,
  });

  factory PhotoRoastState.initial() {
    return const PhotoRoastState(
      isLoading: false,
      groups: <QualityPhotoGroup>[],
      error: null,
    );
  }

  final bool isLoading;
  final List<QualityPhotoGroup> groups;
  final String? error;

  PhotoRoastState copyWith({
    bool? isLoading,
    List<QualityPhotoGroup>? groups,
    String? error,
    bool clearError = false,
  }) {
    return PhotoRoastState(
      isLoading: isLoading ?? this.isLoading,
      groups: groups ?? this.groups,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoading,
        groups,
        error,
      ];
}
