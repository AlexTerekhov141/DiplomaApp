import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../models/PhotoRoastModels/RoastIssue.dart';

class PhotoRoastState extends Equatable {
  const PhotoRoastState({
    required this.imageBytes,
    required this.isAnalyzing,
    required this.score,
    required this.issues,
    this.error,
  });

  factory PhotoRoastState.initial() {
    return const PhotoRoastState(
      imageBytes: null,
      isAnalyzing: false,
      score: null,
      issues: <RoastIssue>[],
      error: null,
    );
  }

  final Uint8List? imageBytes;
  final bool isAnalyzing;
  final int? score;
  final List<RoastIssue> issues;
  final String? error;

  bool get hasImage => imageBytes != null && imageBytes!.isNotEmpty;
  bool get hasResult => score != null && issues.isNotEmpty;

  PhotoRoastState copyWith({
    Uint8List? imageBytes,
    bool keepImageBytes = true,
    bool? isAnalyzing,
    int? score,
    bool keepScore = true,
    List<RoastIssue>? issues,
    String? error,
    bool clearError = false,
  }) {
    return PhotoRoastState(
      imageBytes: keepImageBytes ? (imageBytes ?? this.imageBytes) : null,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      score: keepScore ? (score ?? this.score) : score,
      issues: issues ?? this.issues,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    imageBytes,
    isAnalyzing,
    score,
    issues,
    error,
  ];
}
