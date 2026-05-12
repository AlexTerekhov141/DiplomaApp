import 'CleanupSeggestionStatus.dart';
import 'CleanupSuggestionType.dart';

class CleanupSuggestion {
  const CleanupSuggestion({
    required this.assetId,
    required this.type,
    required this.status,
    required this.score,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    this.groupId,
    this.features,
  });

  final String assetId;
  final CleanupSuggestionType type;
  final CleanupSuggestionStatus status;
  final double score;
  final String reason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupId;
  final Map<String, dynamic>? features;
}



