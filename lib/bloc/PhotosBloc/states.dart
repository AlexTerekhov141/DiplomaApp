import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotosState extends Equatable {

  const PhotosState({
    required this.photos,
    this.isLoading = false,
    this.error,
  });

  factory PhotosState.initial() {
    return const PhotosState(photos: <AssetEntity>[]);
  }
  final List<AssetEntity> photos;
  final bool isLoading;
  final String? error;

  PhotosState copyWith({
    List<AssetEntity>? photos,
    bool? isLoading,
    String? error,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[photos, isLoading, error];
}
