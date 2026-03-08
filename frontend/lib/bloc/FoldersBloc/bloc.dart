import 'package:categorize_app/models/Folders/FolderResponse.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/FolderTagsRepository.dart';
import 'events.dart';
import 'states.dart';


class FoldersBloc extends Bloc<FoldersEvent, FoldersState> {

  FoldersBloc(this.repository) : super(const FoldersState()) {
    on<LoadFolders>(_onLoadFolders);
    on<ClearFolders>(_onClearFolders);
  }
  final FolderTagsRepository repository;

  Future<void> _onLoadFolders(
      LoadFolders event,
      Emitter<FoldersState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final FolderResponse response = await repository.fetchFolders(
        forceRefresh: event.forceRefresh,
      );
      emit(state.copyWith(
        isLoading: false,
        folders: response.folders,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearFolders(
    ClearFolders event,
    Emitter<FoldersState> emit,
  ) {
    emit(const FoldersState());
  }
}
