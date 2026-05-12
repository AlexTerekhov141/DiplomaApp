import '../../../models/CleanUp/CleanupSeggestionStatus.dart';
import '../../../models/CleanUp/CleanupStats.dart';
import '../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../models/CleanUp/CleanupSuggestionGroup.dart';
import '../../../models/CleanUp/CleanupSuggestionType.dart';

abstract class CleanupStorage {
  Future<CleanupSuggestion?> getSuggestion(String assetId);

  Future<List<CleanupSuggestion>> getSuggestionsByType(CleanupSuggestionType type,);

  Future<List<CleanupSuggestionGroup>> getSuggestionGroups();

  Future<void> upsertSuggestion(CleanupSuggestion suggestion);

  Future<void> upsertSuggestions(List<CleanupSuggestion> suggestions);

  Future<void> updateStatus(String assetId, CleanupSuggestionStatus status,);

  Future<void> updateStatusByType(CleanupSuggestionType type, CleanupSuggestionStatus status,);

  Future<void> updateAllStatus(CleanupSuggestionStatus status);

  Future<void> deleteMissingAssets(Set<String> existingAssetIds);

  Future<CleanupStats> getStats();

  Future<void> clear();
}
