import '../../models/CleanUp/CleanupSuggestionType.dart';

abstract class CleanupEvent {}


class LoadCleanupGroups extends CleanupEvent {}

class StartCleanupAnalysis extends CleanupEvent {
  StartCleanupAnalysis({this.batchSize = 10});

  final int batchSize;
}

class ProcessCleanupBatch extends CleanupEvent {
  ProcessCleanupBatch({this.batchSize = 10});

  final int batchSize;
}

class StopCleanupAnalysis extends CleanupEvent {}

class LoadCleanupSuggestionsByType extends CleanupEvent {
  LoadCleanupSuggestionsByType(this.type);

  final CleanupSuggestionType type;
}


class KeepCleanupSuggestion extends CleanupEvent {
  KeepCleanupSuggestion(this.assetId);

  final String assetId;
}

class MoveCleanupSuggestionToTrash extends CleanupEvent {
  MoveCleanupSuggestionToTrash(this.assetId);

  final String assetId;
}


class MoveCleanupGroupToTrash extends CleanupEvent {
  MoveCleanupGroupToTrash(this.type);

  final CleanupSuggestionType type;
}

class MoveAllCleanupSuggestionsToTrash extends CleanupEvent {}
