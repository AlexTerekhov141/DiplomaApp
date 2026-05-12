import 'CleanupSuggestionType.dart';

class CleanupSuggestionGroup {
  const CleanupSuggestionGroup({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.previewAssetIds,
  });

  final CleanupSuggestionType type;
  final String title;
  final String subtitle;
  final int count;
  final List<String> previewAssetIds;
}
