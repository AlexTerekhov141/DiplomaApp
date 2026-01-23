import 'package:equatable/equatable.dart';
import '../../models/Folders/Folder.dart';


class FoldersState extends Equatable {

  const FoldersState({
    this.isLoading = false,
    this.folders = const <Folder>[],
    this.error,
  });
  final bool isLoading;
  final List<Folder> folders;
  final String? error;

  FoldersState copyWith({
    bool? isLoading,
    List<Folder>? folders,
    String? error,
  }) {
    return FoldersState(
      isLoading: isLoading ?? this.isLoading,
      folders: folders ?? this.folders,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, folders, error];
}
