import 'package:categorize_app/repository/NotificationsRepository/NotificationsRepository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../repository/ForegroundTaskRepository/ForegroundTaskRepository.dart';
import '../../repository/PhotosRepository/PhotosRepository.dart';
import '../../repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';
import 'events.dart';
import 'states.dart';

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  PhotosBloc({required this.repository, required this.notifications, required this.foregroundTaskRepository,}) : super(PhotosState.initial()) {
    on<PhotosLoadEvent>(_onLoadPhotos);
    on<PhotosSyncToServerEvent>(_onSyncPhotosToServer);
    on<PhotosResetEvent>(_onReset);
    on<PhotosRefreshProcessingStatusEvent>(_onRefreshProcessingStatus);
    on<StartLocalProcessingEvent>(_onStartLocalProcessing);
    on<StopLocalProcessingEvent>(_onStopLocalProcessing);
    on<ResumeLocalProcessingEvent>(_onResumeLocalProcessing);
    on<ProcessNextBatchEvent>(_onProcessNextBatch);
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    add(LoadFavoritesEvent());
    on<LoadTrashEvent>(_onLoadTrash);
    on<ToggleTrashEvent>(_onToggleTrash);
    add(LoadTrashEvent());
  }
  final ProccessingRouterRepository repository;
  bool _stopLocalProcessingRequested = false;

  final Notificationsrepository notifications;

  final ForegroundTaskRepository foregroundTaskRepository;

  Future<PhotosRepository> _activeRepo() => repository.changeMode();

  Future<void> _onLoadPhotos(PhotosLoadEvent event, Emitter<PhotosState> emit,) async {
    final PhotosRepository photosRepository = await _activeRepo();
    emit(state.copyWith(isLoading: true));

    final bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (isDesktop) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Photos are not supported on desktop yet',
      ));
      return;
    }

    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Permission denied',
        ));
        return;
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          orders: const <OrderOption>[
            OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

      if (albums.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final AssetPathEntity recentAlbum = albums.first;

      int page = 0;
      const int pageSize = 100;
      final List<AssetEntity> allPhotos = <AssetEntity>[];
      final Set<String> seenAssetIds = <String>{};

      while (true) {
        final List<AssetEntity> photos = await recentAlbum.getAssetListPaged(
          page: page,
          size: pageSize,
        );

        if (photos.isEmpty) {
          break;
        }

        for (final AssetEntity photo in photos) {
          if (seenAssetIds.add(photo.id)) {
            allPhotos.add(photo);
          }
        }
        page++;
      }

      final Set<String> favoriteIds = await photosRepository.getFavoriteIds();
      emit(
        state.copyWith(
          photos: allPhotos,
          favoriteIds: favoriteIds,
          isLoading: false,
          error: null,
        ),
      );
    } on MissingPluginException {
      emit(state.copyWith(
        isLoading: false,
        error: 'Photos are not available on this platform',
      ));
    }
  }

  Future<void> _onSyncPhotosToServer(PhotosSyncToServerEvent event, Emitter<PhotosState> emit,) async {
    if (event.photos.isEmpty) {
      return;
    }
    final PhotosRepository photosRepository = await _activeRepo();

    emit(state.copyWith(isSyncing: true, syncError: null));

    try {
      final int uploaded =
          await photosRepository.bulkUploadLocalPhotos(event.photos);
      emit(state.copyWith(
        isSyncing: false,
        uploadedCount: uploaded,
        syncError: null,
      ));
      add(PhotosRefreshProcessingStatusEvent());
    } catch (e) {
      final String message = e.toString();
      final bool noToken = message.contains('No token');
      emit(state.copyWith(
        isSyncing: false,
        syncError: noToken ? null : message,
      ));
      add(PhotosRefreshProcessingStatusEvent());
    }
  }

  Future<void> _onRefreshProcessingStatus(PhotosRefreshProcessingStatusEvent event, Emitter<PhotosState> emit,) async {
    emit(state.copyWith(isProcessingStatusLoading: true));
    final PhotosRepository photosRepository = await _activeRepo();
    try {
      final Map<String, int> stats =
          await photosRepository.getRemoteProcessingStats();
      emit(state.copyWith(
        isProcessingStatusLoading: false,
        remoteTotalCount: stats['total'] ?? 0,
        remoteProcessedCount: stats['processed'] ?? 0,
        remotePendingCount: stats['pending'] ?? 0,
      ));
    } catch (e) {
      final bool noToken = e.toString().contains('No token');
      emit(state.copyWith(
        isProcessingStatusLoading: false,
        remoteTotalCount: noToken ? 0 : state.remoteTotalCount,
        remoteProcessedCount: noToken ? 0 : state.remoteProcessedCount,
        remotePendingCount: noToken ? 0 : state.remotePendingCount,
      ));
    }
  }

  Future<void> _onStartLocalProcessing(StartLocalProcessingEvent event, Emitter<PhotosState> emit,) async {
    await notifications.requestPermissions();
    final bool isOfflineMode = await repository.isOfflineMode();
    if (!isOfflineMode) {
      emit(state.copyWith(
        localProcessingError:
            'Local processing is available only in offline mode',
      ));
      return;
    }

    final bool isDesktop = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (isDesktop) {
      emit(state.copyWith(
        isLocalProcessing: false,
        isLocalProcessingPaused: false,
        localProcessingError:
            'Local photo processing is not supported on desktop',
      ));
      return;
    }

    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      emit(state.copyWith(
        isLocalProcessing: false,
        isLocalProcessingPaused: false,
        localProcessingError: 'Permission denied',
      ));
      return;
    }

    await notifications.showProcessingStarted();

    _stopLocalProcessingRequested = false;
    final PhotosRepository photosRepository = await _activeRepo();
    final Map<String, int> stats =
        await photosRepository.getRemoteProcessingStats();
    final int processed = stats['processed'] ?? 0;
    final int total = stats['total'] ?? 0;
    final int pending = stats['pending'] ?? 0;

    emit(state.copyWith(
      isLocalProcessing: true,
      isLocalProcessingPaused: false,
      localProcessedCount: processed,
      localTotalCount: total,
      localPendingCount: pending,
      localProcessingMessage: 'Starting local processing...',
      localProcessingError: null,
    ));

    if (pending <= 0) {
      await notifications.showProcessingCompleted(total);
      emit(state.copyWith(
        isLocalProcessing: false,
        isLocalProcessingPaused: false,
        localProcessingMessage: 'All photos are already categorized',
        localProcessingError: null,
      ));
      return;
    }

    await _safeStartForegroundService(processed: processed, total: total);
    await notifications.showProcessingProgress(processed, total);
    add(ProcessNextBatchEvent(batchSize: event.batchSize));
  }

  Future<void> _onStopLocalProcessing(StopLocalProcessingEvent event, Emitter<PhotosState> emit,) async {
    _stopLocalProcessingRequested = true;
    await notifications.showProcessingPaused(
      state.localProcessedCount,
      state.localTotalCount,
    );
    await _safeStopForegroundService();
    emit(state.copyWith(
      isLocalProcessing: false,
      isLocalProcessingPaused: true,
      localProcessingMessage: 'Processing paused',
      localProcessingError: null,
    ));
  }

  Future<void> _onResumeLocalProcessing(ResumeLocalProcessingEvent event, Emitter<PhotosState> emit,) async {
    _stopLocalProcessingRequested = false;
    await notifications.showProcessingStarted();
    await _safeStartForegroundService(
      processed: state.localProcessedCount,
      total: state.localTotalCount,
    );
    emit(state.copyWith(
      isLocalProcessing: true,
      isLocalProcessingPaused: false,
      localProcessingMessage: 'Resuming local processing...',
      localProcessingError: null,
    ));
    add(ProcessNextBatchEvent(batchSize: event.batchSize));
  }

  Future<void> _onProcessNextBatch(ProcessNextBatchEvent event, Emitter<PhotosState> emit,) async {
    if (!state.isLocalProcessing ||
        state.isLocalProcessingPaused ||
        _stopLocalProcessingRequested) {
      return;
    }

    final PhotosRepository photosRepository = await _activeRepo();

    try {
      final int processedInBatch = await photosRepository.processNextBatch(
        batchSize: event.batchSize,
      );
      final Map<String, int> stats = await photosRepository.getRemoteProcessingStats();
      final int total = stats['total'] ?? state.localTotalCount;
      final int processed = stats['processed'] ?? state.localProcessedCount;
      final int pending = stats['pending'] ?? state.localPendingCount;

      await _safeUpdateForegroundProgress(processed: processed, total: total);
      await notifications.showProcessingProgress(processed, total);

      if (_stopLocalProcessingRequested) {
        await notifications.showProcessingPaused(processed, total);
        await _safeStopForegroundService();
        emit(state.copyWith(
          isLocalProcessing: false,
          isLocalProcessingPaused: true,
          localProcessedCount: processed,
          localTotalCount: total,
          localPendingCount: pending,
          localProcessingMessage: 'Processing paused',
          localProcessingError: null,
        ));
        return;
      }

      if (pending <= 0) {
        await notifications.showProcessingCompleted(total);
        await _safeStopForegroundService();
        emit(state.copyWith(
          isLocalProcessing: false,
          isLocalProcessingPaused: false,
          localProcessedCount: processed,
          localTotalCount: total,
          localPendingCount: 0,
          localProcessingMessage: 'Local categorization completed',
          localProcessingError: null,
        ));
        return;
      }

      if (processedInBatch <= 0) {
        await _safeStopForegroundService();
        emit(state.copyWith(
          isLocalProcessing: false,
          isLocalProcessingPaused: false,
          localProcessedCount: processed,
          localTotalCount: total,
          localPendingCount: pending,
          localProcessingMessage: 'No more photos could be processed right now',
          localProcessingError: null,
        ));
        return;
      }

      emit(state.copyWith(
        isLocalProcessing: true,
        isLocalProcessingPaused: false,
        localProcessedCount: processed,
        localTotalCount: total,
        localPendingCount: pending,
        localProcessingMessage: 'Processing photos locally...',
        localProcessingError: null,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 5));
      add(ProcessNextBatchEvent(batchSize: event.batchSize));
    } catch (e) {
      await _safeStopForegroundService();
      emit(state.copyWith(
        isLocalProcessing: false,
        isLocalProcessingPaused: false,
        localProcessingError: e.toString(),
      ));
    }
  }

  Future<void> _safeStartForegroundService({required int processed, required int total,}) async {
    try {
      await foregroundTaskRepository.startProcessingService();
      await foregroundTaskRepository.updateProgress(processed, total);
    } catch (e) {
      debugPrint('Foreground task start failed: $e');
    }
  }

  Future<void> _safeUpdateForegroundProgress({required int processed, required int total,}) async {
    try {
      await foregroundTaskRepository.updateProgress(processed, total);
    } catch (e) {
      debugPrint('Foreground task update failed: $e');
    }
  }

  Future<void> _safeStopForegroundService() async {
    try {
      await foregroundTaskRepository.stopProcessingService();
    } catch (e) {
      debugPrint('Foreground task stop failed: $e');
    }
  }

  Future<void> _onReset(PhotosResetEvent event, Emitter<PhotosState> emit,) async {
    await _safeStopForegroundService();
    emit(PhotosState.initial());
  }

  Future<void> _onLoadFavorites(LoadFavoritesEvent event, Emitter<PhotosState> emit,) async {
    final PhotosRepository photosRepository = await _activeRepo();
    final Set<String> favoriteIds = await photosRepository.getFavoriteIds();
    emit(state.copyWith(favoriteIds: favoriteIds));
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<PhotosState> emit,) async {
    final PhotosRepository photosRepository = await _activeRepo();
    final Set<String> previousIds = Set<String>.from(state.favoriteIds);
    final Set<String> updatedIds = Set<String>.from(previousIds);
    final bool wasFavorite = updatedIds.contains(event.assetId);
    if (wasFavorite) {
      updatedIds.remove(event.assetId);
    } else {
      updatedIds.add(event.assetId);
    }

    emit(state.copyWith(favoriteIds: updatedIds));

    try {
      await photosRepository.toggleFavorite(event.assetId);
    } catch (_) {
      emit(state.copyWith(favoriteIds: previousIds));
    }
  }

  Future<void> _onLoadTrash(LoadTrashEvent event, Emitter<PhotosState> emit,) async {
    final PhotosRepository photosRepository = await _activeRepo();
    final Set<String> trashedIds = await photosRepository.getTrashedIds();
    emit(state.copyWith(trashedIds: trashedIds));
  }

  Future<void> _onToggleTrash(ToggleTrashEvent event, Emitter<PhotosState> emit,) async {
    final PhotosRepository photosRepository = await _activeRepo();
    final Set<String> previousIds = Set<String>.from(state.trashedIds);
    final Set<String> updatedIds = Set<String>.from(previousIds);
    final bool wasTrash = updatedIds.contains(event.assetId);
    if (wasTrash) {
      updatedIds.remove(event.assetId);
    } else {
      updatedIds.add(event.assetId);
    }

    emit(state.copyWith(trashedIds: updatedIds));

    try {
      await photosRepository.toggleTrash(event.assetId);
    } catch (_) {
      emit(state.copyWith(trashedIds: previousIds));
    }
  }
}
