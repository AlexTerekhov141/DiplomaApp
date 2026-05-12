import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/PhotoRoastModels/QualityPhotoGroup.dart';
import '../../repository/PhotoRoastRepository/PhotoRoastRepository.dart';
import 'event.dart';
import 'state.dart';

class PhotoRoastBloc extends Bloc<PhotoRoastEvent, PhotoRoastState> {
  PhotoRoastBloc({required PhotoRoastRepository repository}): _repository = repository, super(PhotoRoastState.initial()) {
    on<PhotoRoastQualityGroupsRequested>(_onQualityGroupsRequested);
    on<PhotoRoastErrorCleared>(
      (_, Emitter<PhotoRoastState> emit) => emit(
        state.copyWith(clearError: true),
      ),
    );
  }

  final PhotoRoastRepository _repository;

  Future<void> _onQualityGroupsRequested(PhotoRoastQualityGroupsRequested event, Emitter<PhotoRoastState> emit,) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final List<QualityPhotoGroup> groups =
          await _repository.getQualityGroups();
      emit(
        state.copyWith(
          isLoading: false,
          groups: groups,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }
}
