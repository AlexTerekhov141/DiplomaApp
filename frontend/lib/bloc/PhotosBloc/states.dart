import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotosState extends Equatable {

  const PhotosState({
    required this.photos,
    this.isLoading = false,
    this.isSyncing = false,
    this.isProcessingStatusLoading = false,
    this.uploadedCount = 0,
    this.remoteTotalCount = 0,
    this.remoteProcessedCount = 0,
    this.remotePendingCount = 0,
    this.error,
    this.syncError,
    this.favoriteIds = const <String>{},
    this.trashedIds = const <String>{},
  });

  factory PhotosState.initial() {
    return const PhotosState(photos: <AssetEntity>[]);
  }
  final List<AssetEntity> photos;
  final bool isLoading;
  final bool isSyncing;
  final bool isProcessingStatusLoading;
  final int uploadedCount;
  final int remoteTotalCount;
  final int remoteProcessedCount;
  final int remotePendingCount;
  final String? error;
  final String? syncError;
  final Set<String> favoriteIds;
  final Set<String> trashedIds;
  List<AssetEntity> get favoritePhotos => photos
      .where((AssetEntity photo) => favoriteIds.contains(photo.id))
      .toList();
  List<AssetEntity> get trashedPhotos => photos
      .where((AssetEntity photo) => trashedIds.contains(photo.id))
      .toList();
  List<AssetEntity> get activePhotos => photos
      .where((AssetEntity photo) => !trashedIds.contains(photo.id))
      .toList();


  PhotosState copyWith({
    List<AssetEntity>? photos,
    bool? isLoading,
    bool? isSyncing,
    bool? isProcessingStatusLoading,
    int? uploadedCount,
    int? remoteTotalCount,
    int? remoteProcessedCount,
    int? remotePendingCount,
    String? error,
    String? syncError,
    Set<String>? favoriteIds,
    Set<String>? trashedIds,
  }) {
    return PhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      isProcessingStatusLoading:
          isProcessingStatusLoading ?? this.isProcessingStatusLoading,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      remoteTotalCount: remoteTotalCount ?? this.remoteTotalCount,
      remoteProcessedCount: remoteProcessedCount ?? this.remoteProcessedCount,
      remotePendingCount: remotePendingCount ?? this.remotePendingCount,
      error: error,
      syncError: syncError,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      trashedIds: trashedIds ?? this.trashedIds,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    photos,
    isLoading,
    isSyncing,
    isProcessingStatusLoading,
    uploadedCount,
    remoteTotalCount,
    remoteProcessedCount,
    remotePendingCount,
    error,
    syncError,
    favoriteIds,
    trashedIds,
  ];
}
