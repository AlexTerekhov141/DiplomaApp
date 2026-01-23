import 'dart:async';

import 'package:categorize_app/bloc/FoldersBloc/states.dart';
import 'package:categorize_app/bloc/PhotosBloc/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../FoldersBloc/bloc.dart';
import '../PhotosBloc/bloc.dart';
import 'events.dart';
import 'states.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {

  StatisticsBloc({
    required this.photosBloc,
    required this.foldersBloc,
  }) : super(const StatisticsState()) {
    on<LoadStatistics>(_onLoadStatistics);

    photosSub = photosBloc.stream.listen((PhotosState photosState) {
      add(LoadStatistics());
    });

    foldersSub = foldersBloc.stream.listen((FoldersState foldersState) {
      add(LoadStatistics());
    });
  }
  final PhotosBloc photosBloc;
  final FoldersBloc foldersBloc;

  late final StreamSubscription photosSub;
  late final StreamSubscription foldersSub;

  void _onLoadStatistics(
      LoadStatistics event,
      Emitter<StatisticsState> emit,
      ) {
    emit(
      state.copyWith(
        photosCount: photosBloc.state.photos.length,
        foldersCount: foldersBloc.state.folders.length,
        tagsCount: 120,
        isLoading: false,
      ),
    );
  }

  @override
  Future<void> close() {
    photosSub.cancel();
    foldersSub.cancel();
    return super.close();
  }
}

