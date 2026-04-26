import '../../models/CleanUp/CleanupStats.dart';
import '../../models/CleanUp/CleanupSuggestion.dart';
import '../../models/CleanUp/CleanupSuggestionGroup.dart';
import '../../models/CleanUp/CleanupSuggestionType.dart';

abstract class CleanupRepository {
  Future<int> analyzeNextBatch({int batchSize = 30});

  Future<List<CleanupSuggestionGroup>> getSuggestionGroups();

  Future<List<CleanupSuggestion>> getSuggestionsByType(CleanupSuggestionType type);

  Future<void> keepSuggestion(String assetId);

  Future<void> moveToTrash(String assetId);

  Future<void> moveGroupToTrash(CleanupSuggestionType type);

  Future<void> moveAllToTrash();

  Future<CleanupStats> getStats();

  Future<void> clear();
}
