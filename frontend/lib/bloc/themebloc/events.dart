abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeSettingsEvent extends ThemeEvent {}

class SetThemeModeEvent extends ThemeEvent {
  SetThemeModeEvent(this.themeMode);
  final ThemeModeValue themeMode;
}

class SetGridSizeEvent extends ThemeEvent {
  SetGridSizeEvent(this.gridSize);
  final GridSizeValue gridSize;
}

enum ThemeModeValue { system, light, dark }

enum GridSizeValue { small, medium, large }
