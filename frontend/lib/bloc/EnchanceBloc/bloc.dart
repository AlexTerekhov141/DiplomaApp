import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'event.dart';
import 'state.dart';

typedef EnchanceProcessor = FutureOr<Uint8List> Function(
  Uint8List originalBytes,
  EnchanceAdjustments adjustments,
);
typedef EnchanceSaver = FutureOr<void> Function(Uint8List editedBytes);

class EnchanceBloc extends Bloc<EnchanceEvent, EnchanceState> {

  EnchanceBloc({
    EnchanceProcessor? processor,
    EnchanceSaver? saver,
  }) : _processor = processor ?? _defaultProcessor,
       _saver = saver ?? _defaultSaver,
       super(EnchanceState.initial()) {
    on<EnchanceImageLoaded>(_onImageLoaded);
    on<EnchanceAutoApplied>(_onAutoApplied);
    on<EnchanceAdjustmentsChanged>(_onAdjustmentsChanged);
    on<EnchanceResetRequested>(_onResetRequested);
    on<EnchanceSaveCopyRequested>(_onSaveCopyRequested);
    on<EnchanceErrorCleared>(_onErrorCleared);
  }
  static const String _noPhotoError = 'Select a photo first.';
  static const String _nothingToSaveError = 'Nothing to save yet.';

  final EnchanceProcessor _processor;
  final EnchanceSaver _saver;

  static FutureOr<Uint8List> _defaultProcessor(
    Uint8List originalBytes,
    EnchanceAdjustments _,
  ) {
    return originalBytes;
  }

  static FutureOr<void> _defaultSaver(Uint8List _) async {}

  void _onImageLoaded(EnchanceImageLoaded event, Emitter<EnchanceState> emit) {
    emit(
      state.copyWith(
        originalBytes: event.bytes,
        editedBytes: event.bytes,
        adjustments: EnchanceAdjustments.initial(),
        isProcessing: false,
        isSaving: false,
        clearError: true,
      ),
    );
  }

  bool _hasSourceImage(Emitter<EnchanceState> emit) {
    if (state.hasImage) return true;
    emit(state.copyWith(error: _noPhotoError));
    return false;
  }

  Future<void> _onAutoApplied(
    EnchanceAutoApplied event,
    Emitter<EnchanceState> emit,
  ) async {
    if (!_hasSourceImage(emit)) return;

    await _rebuild(
      emit: emit,
      nextAdjustments: EnchanceAdjustments.autoPreset(),
    );
  }

  Future<void> _onAdjustmentsChanged(
    EnchanceAdjustmentsChanged event,
    Emitter<EnchanceState> emit,
  ) async {
    if (!_hasSourceImage(emit)) return;

    final EnchanceAdjustments next = state.adjustments.copyWith(
      brightness: event.brightness,
      contrast: event.contrast,
      saturation: event.saturation,
      sharpness: event.sharpness,
    );
    await _rebuild(emit: emit, nextAdjustments: next);
  }

  void _onResetRequested(
    EnchanceResetRequested event,
    Emitter<EnchanceState> emit,
  ) {
    if (!state.hasImage) {
      emit(EnchanceState.initial());
      return;
    }

    emit(
      state.copyWith(
        editedBytes: state.originalBytes,
        adjustments: EnchanceAdjustments.initial(),
        isProcessing: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onSaveCopyRequested(
    EnchanceSaveCopyRequested event,
    Emitter<EnchanceState> emit,
  ) async {
    final Uint8List? bytesToSave = state.editedBytes ?? state.originalBytes;
    if (bytesToSave == null || bytesToSave.isEmpty) {
      emit(state.copyWith(error: _nothingToSaveError));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _saver(bytesToSave);
      emit(state.copyWith(isSaving: false, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          error: 'Failed to save edited photo: $e',
        ),
      );
    }
  }

  void _onErrorCleared(
    EnchanceErrorCleared event,
    Emitter<EnchanceState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _rebuild({
    required Emitter<EnchanceState> emit,
    required EnchanceAdjustments nextAdjustments,
  }) async {
    final Uint8List? source = state.originalBytes;
    if (source == null || source.isEmpty) {
      emit(state.copyWith(error: _noPhotoError));
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        adjustments: nextAdjustments,
        clearError: true,
      ),
    );
    try {
      final Uint8List edited = await _processor(source, nextAdjustments);
      emit(
        state.copyWith(
          editedBytes: edited,
          isProcessing: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isProcessing: false,
          error: 'Failed to apply adjustments: $e',
        ),
      );
    }
  }
}
