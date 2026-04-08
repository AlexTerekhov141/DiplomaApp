import 'dart:typed_data';

import 'package:categorize_app/models/PhotoRoastModels/RoastIssue.dart';
import 'package:categorize_app/models/PhotoRoastModels/RoastResult.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/PhotoRoastRepository/PhotoRoastRepository.dart';
import 'event.dart';
import 'state.dart';

class PhotoRoastBloc extends Bloc<PhotoRoastEvent, PhotoRoastState> {
  PhotoRoastBloc({required PhotoRoastRepository repository})
      : _repository = repository,
        super(PhotoRoastState.initial()) {
    on<PhotoRoastImageLoaded>(_onImageLoaded);
    on<PhotoRoastAnalyzeRequested>(_onAnalyze);
    on<PhotoRoastResetRequested>((_, Emitter<PhotoRoastState> emit) => emit(PhotoRoastState.initial()));
    on<PhotoRoastErrorCleared>((_, Emitter<PhotoRoastState> emit) => emit(state.copyWith(clearError: true)));
  }

  final PhotoRoastRepository _repository;

  Future<void> _onImageLoaded(PhotoRoastImageLoaded e, Emitter<PhotoRoastState> emit) async {
    emit(state.copyWith(imageBytes: e.bytes, score: null, keepScore: false, issues: const <RoastIssue>[], clearError: true));
    add(const PhotoRoastAnalyzeRequested());
  }

  Future<void> _onAnalyze(PhotoRoastAnalyzeRequested e, Emitter<PhotoRoastState> emit) async {
    final Uint8List? bytes = state.imageBytes;
    if (bytes == null || bytes.isEmpty) {
      emit(state.copyWith(error: 'Pick a photo first.'));
      return;
    }

    emit(state.copyWith(isAnalyzing: true, clearError: true));
    try {
      final RoastResult result = await _repository.run(bytes);
      emit(state.copyWith(isAnalyzing: false, score: result.score, issues: result.issues));
    } catch (err) {
      emit(state.copyWith(isAnalyzing: false, error: 'Failed to analyze photo: $err'));
    }
  }
}
