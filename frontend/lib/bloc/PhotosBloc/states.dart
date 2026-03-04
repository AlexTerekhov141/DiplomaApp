import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotosState extends Equatable {

  const PhotosState({
    required this.photos,
    this.isLoading = false,
    this.isSyncing = false,
    this.uploadedCount = 0,
    this.error,
    this.syncError,
  });

  factory PhotosState.initial() {
    return const PhotosState(photos: <AssetEntity>[]);
  }
  final List<AssetEntity> photos;
  final bool isLoading;
  final bool isSyncing;
  final int uploadedCount;
  final String? error;
  final String? syncError;

  PhotosState copyWith({
    List<AssetEntity>? photos,
    bool? isLoading,
    bool? isSyncing,
    int? uploadedCount,
    String? error,
    String? syncError,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      error: error,
      syncError: syncError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    photos,
    isLoading,
    isSyncing,
    uploadedCount,
    error,
    syncError,
  ];
}
