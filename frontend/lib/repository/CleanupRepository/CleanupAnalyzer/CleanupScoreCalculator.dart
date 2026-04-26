import '../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../models/CleanUp/CleanupSuggestionType.dart';

class CleanupScoreCalculator {
  const CleanupScoreCalculator();

  CleanupSuggestion? pickBest(
    Iterable<CleanupSuggestion?> suggestions,
  ) {
    CleanupSuggestion? best;

    for (final CleanupSuggestion? suggestion in suggestions) {
      if (suggestion == null) {
        continue;
      }

      if (best == null || suggestion.score > best.score) {
        best = suggestion;
      }
    }

    return best;
  }

  List<CleanupSuggestion> mergeByAssetId(
    Iterable<CleanupSuggestion> suggestions,
  ) {
    final Map<String, CleanupSuggestion> merged =
        <String, CleanupSuggestion>{};

    for (final CleanupSuggestion suggestion in suggestions) {
      final CleanupSuggestion? existing = merged[suggestion.assetId];
      if (existing == null || suggestion.score > existing.score) {
        merged[suggestion.assetId] = suggestion;
      }
    }

    return merged.values.toList()
      ..sort(
        (CleanupSuggestion a, CleanupSuggestion b) =>
            b.score.compareTo(a.score),
      );
  }

  double scoreForType(
    CleanupSuggestionType type, {
    required double confidence,
  }) {
    final double base = switch (type) {
      CleanupSuggestionType.expired => 0.78,
      CleanupSuggestionType.duplicate => 0.7,
      CleanupSuggestionType.badQuality => 0.62,
      CleanupSuggestionType.screenshot => 0.58,
      CleanupSuggestionType.document => 0.54,
    };

    final double normalizedConfidence = confidence.clamp(0.0, 1.0).toDouble();
    return (base + normalizedConfidence * 0.2).clamp(0.0, 1.0).toDouble();
  }
}
