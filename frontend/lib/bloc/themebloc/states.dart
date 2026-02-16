import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GalleryGridSize { small, medium, large }

class ThemeState extends Equatable {
  const ThemeState({required this.themeMode, required this.gridSize});

  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: ThemeMode.system,
      gridSize: GalleryGridSize.medium,
    );
  }

  final ThemeMode themeMode;
  final GalleryGridSize gridSize;

  ThemeState copyWith({ThemeMode? themeMode, GalleryGridSize? gridSize}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      gridSize: gridSize ?? this.gridSize,
    );
  }

  @override
  List<Object?> get props => <Object?>[themeMode, gridSize];
}
