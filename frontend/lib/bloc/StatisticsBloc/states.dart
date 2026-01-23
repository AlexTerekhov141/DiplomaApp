import 'package:equatable/equatable.dart';

class StatisticsState extends Equatable {

  const StatisticsState({
    this.photosCount = 0,
    this.foldersCount = 0,
    this.tagsCount = 0,
    this.isLoading = false,
    this.error,
  });
  final int photosCount;
  final int foldersCount;
  final int tagsCount;
  final bool isLoading;
  final String? error;

  StatisticsState copyWith({
    int? photosCount,
    int? foldersCount,
    int? tagsCount,
    bool? isLoading,
    String? error,
  }) {
    return StatisticsState(
      photosCount: photosCount ?? this.photosCount,
      foldersCount: foldersCount ?? this.foldersCount,
      tagsCount: tagsCount ?? this.tagsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[photosCount, foldersCount, tagsCount, isLoading, error];
}
