import 'package:categorize_app/models/CleanUp/CleanupStats.dart';
import 'package:categorize_app/models/CleanUp/CleanupSuggestionGroup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/CleanUp/CleanupSuggestion.dart';
import '../../models/CleanUp/CleanupSuggestionType.dart';
import '../../repository/CleanupRepository/CleanupRepository.dart';
import 'events.dart';
import 'states.dart';

class CleanupBloc extends Bloc<CleanupEvent, CleanupState> {
  CleanupBloc({required  this.repository}): super(const CleanupState()){
    on<LoadCleanupGroups>(_onLoadCleanupGroups);
    on<StartCleanupAnalysis>(_onStartCleanupAnalysis);
    on<ProcessCleanupBatch>(_onProcessCleanupBatch);
    on<StopCleanupAnalysis>(_onStopCleanupAnalysis);
    on<LoadCleanupSuggestionsByType>(_onLoadCleanupSuggestionsByType);
    on<KeepCleanupSuggestion>(_onKeepCleanupSuggestion);
    on<MoveCleanupSuggestionToTrash>(_onMoveCleanupSuggestionToTrash);
    on<MoveCleanupGroupToTrash>(_onMoveCleanupGroupToTrash);
    on<MoveAllCleanupSuggestionsToTrash>(_onMoveAllCleanupSuggestionsToTrash);
  }

  final CleanupRepository repository;
  bool _stopRequested = false;



  Future<void> _onLoadCleanupGroups(LoadCleanupGroups event, Emitter<CleanupState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final List<CleanupSuggestionGroup> groups = await repository.getSuggestionGroups();
      final CleanupStats stats = await repository.getStats();
      emit(state.copyWith(
          groups: groups,
          stats: stats,
          isLoading: false,
          clearError: true
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }

  }



  Future<void> _onStartCleanupAnalysis(StartCleanupAnalysis event, Emitter<CleanupState> emit) async {
    if (state.isAnalyzing) {
      return;
    }

    _stopRequested = false;
    emit(state.copyWith(
        isAnalyzing: true,
        clearError: true,
        isPaused: false,
        processedCount: 0,
        lastBatchProcessed: 0,
        message: 'Cleanup started',
    ));
    add(ProcessCleanupBatch(batchSize: event.batchSize));
  }

  Future<void> _onProcessCleanupBatch(ProcessCleanupBatch event, Emitter<CleanupState> emit,) async {
    if (!state.isAnalyzing || _stopRequested) {
      return;
    }

    try {
      final int processed = await repository.analyzeNextBatch(
        batchSize: event.batchSize,
      );

      final List<CleanupSuggestionGroup> groups = await repository.getSuggestionGroups();
      final CleanupStats stats = await repository.getStats();

      final int totalProcessed = state.processedCount + processed;

      emit(state.copyWith(
        groups: groups,
        stats: stats,
        processedCount: totalProcessed,
        lastBatchProcessed: processed,
        isAnalyzing: processed > 0,
        message: processed > 0 ? 'Analyzing photos...' : 'Cleanup analysis finished',
        clearError: true,
      ));

      if (processed > 0 && !_stopRequested) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        add(ProcessCleanupBatch(batchSize: event.batchSize));
      }
    } catch (e) {
      emit(state.copyWith(
        isAnalyzing: false,
        error: e.toString(),
      ));
    }
  }


  Future<void> _onStopCleanupAnalysis(StopCleanupAnalysis event, Emitter<CleanupState> emit,) async {
    _stopRequested = true;
    emit(state.copyWith(
      isAnalyzing: false,
      isPaused: true,
      message: 'Cleanup analysis paused',
    ));
  }


  Future<void> _onLoadCleanupSuggestionsByType(LoadCleanupSuggestionsByType event, Emitter<CleanupState> emit,) async {
    emit(state.copyWith(
      isLoading: true,
      selectedType: event.type,
      clearError: true,
    ));

    try {
      final List<CleanupSuggestion> suggestions = await repository.getSuggestionsByType(event.type);

      emit(state.copyWith(
        isLoading: false,
        selectedType: event.type,
        suggestions: suggestions,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }


  Future<void> _onKeepCleanupSuggestion(KeepCleanupSuggestion event, Emitter<CleanupState> emit,) async {
    await repository.keepSuggestion(event.assetId);

    final CleanupSuggestionType? selectedType = state.selectedType;
    if (selectedType != null) {
      final List<CleanupSuggestion> suggestions = await repository.getSuggestionsByType(selectedType);
      final List<CleanupSuggestionGroup> groups = await repository.getSuggestionGroups();
      final CleanupStats stats = await repository.getStats();

      emit(state.copyWith(
        suggestions: suggestions,
        groups: groups,
        stats: stats,
        message: 'Photo kept',
        clearError: true,
      ));
    } else {
      add(LoadCleanupGroups());
    }
  }

  Future<void> _onMoveCleanupSuggestionToTrash(MoveCleanupSuggestionToTrash event, Emitter<CleanupState> emit,) async {
    await repository.moveToTrash(event.assetId);

    final CleanupSuggestionType? selectedType = state.selectedType;
    if (selectedType != null) {
      final List<CleanupSuggestion> suggestions = await repository.getSuggestionsByType(selectedType);
      final List<CleanupSuggestionGroup> groups = await repository.getSuggestionGroups();
      final CleanupStats stats = await repository.getStats();

      emit(state.copyWith(
        suggestions: suggestions,
        groups: groups,
        stats: stats,
        message: 'Moved to trash',
        clearError: true,
      ));
    } else {
      add(LoadCleanupGroups());
    }
  }


  Future<void> _onMoveCleanupGroupToTrash(MoveCleanupGroupToTrash event, Emitter<CleanupState> emit,) async {
    await repository.moveGroupToTrash(event.type);

    final List<CleanupSuggestionGroup> groups = await repository.getSuggestionGroups();
    final CleanupStats stats = await repository.getStats();

    emit(state.copyWith(
      groups: groups,
      stats: stats,
      suggestions: state.selectedType == event.type ? const <CleanupSuggestion>[] : state.suggestions,
      message: 'Group moved to trash',
      clearError: true,
    ));
  }


  Future<void> _onMoveAllCleanupSuggestionsToTrash(MoveAllCleanupSuggestionsToTrash event, Emitter<CleanupState> emit,) async {
    await repository.moveAllToTrash();

    final List<CleanupSuggestionGroup> groups = await repository.getSuggestionGroups();
    final CleanupStats stats = await repository.getStats();

    emit(state.copyWith(
      groups: groups,
      suggestions: const <CleanupSuggestion>[],
      stats: stats,
      message: 'All suggestions moved to trash',
      clearError: true,
    ));
  }

}
