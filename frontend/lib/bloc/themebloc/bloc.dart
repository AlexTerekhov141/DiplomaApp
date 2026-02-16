import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'events.dart';
import 'states.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required this.storage}) : super(ThemeState.initial()) {
    on<LoadThemeSettingsEvent>(_onLoadSettings);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
    on<SetGridSizeEvent>(_onSetGridSize);
  }

  final FlutterSecureStorage storage;
  static const String _themeModeKey = 'app_theme_mode';
  static const String _gridSizeKey = 'app_gallery_grid_size';

  Future<void> _onLoadSettings(
    LoadThemeSettingsEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final String? themeModeRaw = await storage.read(key: _themeModeKey);
    final String? gridSizeRaw = await storage.read(key: _gridSizeKey);

    emit(
      state.copyWith(
        themeMode: _themeModeFromString(themeModeRaw),
        gridSize: _gridSizeFromString(gridSizeRaw),
      ),
    );
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final ThemeMode nextMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await storage.write(
      key: _themeModeKey,
      value: _themeModeToString(nextMode),
    );
    emit(state.copyWith(themeMode: nextMode));
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final ThemeMode themeMode = _themeModeFromValue(event.themeMode);
    await storage.write(
      key: _themeModeKey,
      value: _themeModeToString(themeMode),
    );
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> _onSetGridSize(
    SetGridSizeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final GalleryGridSize gridSize = _gridSizeFromValue(event.gridSize);
    await storage.write(key: _gridSizeKey, value: _gridSizeToString(gridSize));
    emit(state.copyWith(gridSize: gridSize));
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode value) {
    switch (value) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _themeModeFromValue(ThemeModeValue value) {
    switch (value) {
      case ThemeModeValue.light:
        return ThemeMode.light;
      case ThemeModeValue.dark:
        return ThemeMode.dark;
      case ThemeModeValue.system:
        return ThemeMode.system;
    }
  }

  GalleryGridSize _gridSizeFromString(String? value) {
    switch (value) {
      case 'small':
        return GalleryGridSize.small;
      case 'large':
        return GalleryGridSize.large;
      default:
        return GalleryGridSize.medium;
    }
  }

  String _gridSizeToString(GalleryGridSize value) {
    switch (value) {
      case GalleryGridSize.small:
        return 'small';
      case GalleryGridSize.medium:
        return 'medium';
      case GalleryGridSize.large:
        return 'large';
    }
  }

  GalleryGridSize _gridSizeFromValue(GridSizeValue value) {
    switch (value) {
      case GridSizeValue.small:
        return GalleryGridSize.small;
      case GridSizeValue.medium:
        return GalleryGridSize.medium;
      case GridSizeValue.large:
        return GalleryGridSize.large;
    }
  }
}
