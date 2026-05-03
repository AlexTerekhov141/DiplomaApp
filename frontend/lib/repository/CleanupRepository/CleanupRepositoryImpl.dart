import 'package:photo_manager/photo_manager.dart';

import '../../models/CleanUp/CleanupSeggestionStatus.dart';
import '../../models/CleanUp/CleanupStats.dart';
import '../../models/CleanUp/CleanupSuggestion.dart';
import '../../models/CleanUp/CleanupSuggestionGroup.dart';
import '../../models/CleanUp/CleanupSuggestionType.dart';
import 'CleanupAnalyzer/CleanupScoreCalculator.dart';
import 'CleanupAnalyzer/DuplicateAnalyzer.dart';
import 'CleanupAnalyzer/ImageQualityAnalyzer.dart';
import 'CleanupAnalyzer/MetadataCleanupAnalyzer.dart';
import 'CleanupAnalyzer/OcrCleanupAnalyzer.dart';
import 'CleanupRepository.dart';
import 'CleanupStorage/CleanupStorage.dart';

class CleanupRepositoryImpl implements CleanupRepository {
  CleanupRepositoryImpl({
    required this.storage,
    required this.metadataAnalyzer,
    required this.imageQualityAnalyzer,
    required this.duplicateAnalyzer,
    required this.ocrAnalyzer,
    required this.scoreCalculator,
    this.enableMetadataAnalyzer = true,
    this.enableImageQualityAnalyzer = true,
    this.enableDuplicateAnalyzer = true,
    this.enableOcrAnalyzer = true,
  });

  final CleanupStorage storage;
  final MetadataCleanupAnalyzer metadataAnalyzer;
  final ImageQualityAnalyzer imageQualityAnalyzer;
  final DuplicateAnalyzer duplicateAnalyzer;
  final OcrCleanupAnalyzer ocrAnalyzer;
  final CleanupScoreCalculator scoreCalculator;
  final bool enableMetadataAnalyzer;
  final bool enableImageQualityAnalyzer;
  final bool enableDuplicateAnalyzer;
  final bool enableOcrAnalyzer;

  int _nextPage = 0;

  @override
  Future<int> analyzeNextBatch({int batchSize = 30}) async {
    final int safeBatchSize = batchSize <= 0 ? 1 : batchSize;
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      return 0;
    }

    final AssetPathEntity? recentAlbum = await _getRecentAlbum();
    if (recentAlbum == null) {
      return 0;
    }

    final int totalAssets = await recentAlbum.assetCountAsync;
    if (totalAssets <= 0) {
      return 0;
    }

    final int totalPages = (totalAssets / safeBatchSize).ceil();
    if (_nextPage >= totalPages) {
      _nextPage = 0;
      return 0;
    }

    final List<AssetEntity> batchAssets = await _loadNextBatch(
      recentAlbum,
      totalPages: totalPages,
      pageSize: safeBatchSize,
    );
    if (batchAssets.isEmpty) {
      return 0;
    }

    final List<CleanupSuggestion> suggestions = <CleanupSuggestion>[];

    for (final AssetEntity asset in batchAssets) {
      final CleanupSuggestion? suggestion = await _analyzeAssetSafely(asset);
      if (suggestion != null) {
        suggestions.add(suggestion);
      }
      await Future<void>.delayed(Duration.zero);
    }

    if (enableDuplicateAnalyzer) {
      final List<CleanupSuggestion> duplicateSuggestions =
          await _analyzeDuplicatesSafely(batchAssets);
      suggestions.addAll(duplicateSuggestions);
    }

    final List<CleanupSuggestion> mergedSuggestions =
        scoreCalculator.mergeByAssetId(suggestions);
    await storage.upsertSuggestions(mergedSuggestions);

    return batchAssets.length;
  }

  Future<CleanupSuggestion?> _analyzeAssetSafely(AssetEntity asset) async {
    try {
      final CleanupSuggestion? metadataSuggestion = enableMetadataAnalyzer
          ? await metadataAnalyzer.analyze(asset)
          : null;
      final CleanupSuggestion? qualitySuggestion = enableImageQualityAnalyzer
          ? await imageQualityAnalyzer.analyze(asset)
          : null;
      final CleanupSuggestion? ocrSuggestion = enableOcrAnalyzer
          ? await _analyzeWithOcrIfNeeded(asset, metadataSuggestion)
          : null;

      return scoreCalculator.pickBest(
        <CleanupSuggestion?>[
          metadataSuggestion,
          qualitySuggestion,
          ocrSuggestion,
        ],
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<CleanupSuggestion>> _analyzeDuplicatesSafely(
    List<AssetEntity> assets,
  ) async {
    try {
      return await duplicateAnalyzer.analyzeAll(assets);
    } catch (_) {
      return <CleanupSuggestion>[];
    }
  }

  @override
  Future<void> clear() {
    return storage.clear();
  }

  @override
  Future<CleanupStats> getStats() {
    return storage.getStats();
  }

  @override
  Future<List<CleanupSuggestionGroup>> getSuggestionGroups() {
    return storage.getSuggestionGroups();
  }

  @override
  Future<List<CleanupSuggestion>> getSuggestionsByType(
    CleanupSuggestionType type,
  ) {
    return storage.getSuggestionsByType(type);
  }

  @override
  Future<void> keepSuggestion(String assetId) {
    return storage.updateStatus(
      assetId,
      CleanupSuggestionStatus.kept,
    );
  }

  @override
  Future<void> moveAllToTrash() {
    return storage.updateAllStatus(CleanupSuggestionStatus.trashed);
  }

  @override
  Future<void> moveGroupToTrash(CleanupSuggestionType type) {
    return storage.updateStatusByType(
      type,
      CleanupSuggestionStatus.trashed,
    );
  }

  @override
  Future<void> moveToTrash(String assetId) {
    return storage.updateStatus(
      assetId,
      CleanupSuggestionStatus.trashed,
    );
  }

  Future<CleanupSuggestion?> _analyzeWithOcrIfNeeded(AssetEntity asset, CleanupSuggestion? metadataSuggestion,) async {
    try {
      return await ocrAnalyzer.analyze(asset);
    } catch (_) {
      return null;
    }
  }


  bool _shouldRunOcr(CleanupSuggestion? metadataSuggestion) {
    if (metadataSuggestion == null) {
      return false;
    }

    if (metadataSuggestion.type == CleanupSuggestionType.document) {
      return true;
    }

    if (metadataSuggestion.type != CleanupSuggestionType.screenshot) {
      return false;
    }

    final Map<String, dynamic> features =
        metadataSuggestion.features ?? <String, dynamic>{};
    final String title = (features['title'] ?? '').toString().toLowerCase();
    final String relativePath =
        (features['relative_path'] ?? '').toString().toLowerCase();
    final String text = '$title $relativePath';

    return text.contains('screenshot') ||
        text.contains('screen_shot') ||
        text.contains('screen-shot') ||
        text.contains('screenshots') ||
        text.contains('screencapture') ||
        text.contains('screen_capture') ||
        text.contains('screen-capture');
  }

  Future<AssetPathEntity?> _getRecentAlbum() async {
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
      return null;
    }

    return albums.first;
  }

  Future<List<AssetEntity>> _loadNextBatch(
    AssetPathEntity album, {
    required int totalPages,
    required int pageSize,
  }) async {
    if (totalPages <= 0) {
      return <AssetEntity>[];
    }

    final List<AssetEntity> pageItems = await album.getAssetListPaged(
      page: _nextPage,
      size: pageSize,
    );
    _nextPage++;

    return pageItems
        .where((AssetEntity asset) => asset.type == AssetType.image)
        .toList();
  }
}
