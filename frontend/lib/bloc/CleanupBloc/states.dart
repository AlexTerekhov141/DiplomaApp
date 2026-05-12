import 'package:equatable/equatable.dart';

import '../../models/CleanUp/CleanupStats.dart';
import '../../models/CleanUp/CleanupSuggestion.dart';
import '../../models/CleanUp/CleanupSuggestionGroup.dart';
import '../../models/CleanUp/CleanupSuggestionType.dart';

class CleanupState extends Equatable {
  const CleanupState({
    this.isLoading = false,
    this.isAnalyzing = false,
    this.isPaused = false,
    this.groups = const <CleanupSuggestionGroup>[],
    this.suggestions = const <CleanupSuggestion>[],
    this.selectedType,
    this.processedCount = 0,
    this.lastBatchProcessed = 0,
    this.stats = const CleanupStats(
      total: 0,
      suggested: 0,
      trashed: 0,
      kept: 0,
    ),
    this.message,
    this.error,
  });

  final bool isLoading;
  final bool isAnalyzing;
  final bool isPaused;
  final List<CleanupSuggestionGroup> groups;
  final List<CleanupSuggestion> suggestions;
  final CleanupSuggestionType? selectedType;
  final int processedCount;
  final int lastBatchProcessed;
  final CleanupStats stats;
  final String? message;
  final String? error;

  CleanupState copyWith({
    bool? isLoading,
    bool? isAnalyzing,
    bool? isPaused,
    List<CleanupSuggestionGroup>? groups,
    List<CleanupSuggestion>? suggestions,
    CleanupSuggestionType? selectedType,
    bool clearSelectedType = false,
    int? processedCount,
    int? lastBatchProcessed,
    CleanupStats? stats,
    String? message,
    String? error,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return CleanupState(
      isLoading: isLoading ?? this.isLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isPaused: isPaused ?? this.isPaused,
      groups: groups ?? this.groups,
      suggestions: suggestions ?? this.suggestions,
      selectedType: clearSelectedType ? null : selectedType ?? this.selectedType,
      processedCount: processedCount ?? this.processedCount,
      lastBatchProcessed: lastBatchProcessed ?? this.lastBatchProcessed,
      stats: stats ?? this.stats,
      message: clearMessage ? null : message ?? this.message,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    isAnalyzing,
    isPaused,
    groups,
    suggestions,
    selectedType,
    processedCount,
    lastBatchProcessed,
    stats,
    message,
    error,
  ];
}
