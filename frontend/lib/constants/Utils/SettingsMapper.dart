import 'package:flutter/material.dart';

import '../../../bloc/themebloc/events.dart';
import '../../../bloc/themebloc/states.dart';

String themeModeLabel(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
  }
}

ThemeModeValue themeModeValueFromLabel(String label) {
  switch (label) {
    case 'Light':
      return ThemeModeValue.light;
    case 'Dark':
      return ThemeModeValue.dark;
    default:
      return ThemeModeValue.system;
  }
}

String gridSizeLabel(GalleryGridSize gridSize) {
  switch (gridSize) {
    case GalleryGridSize.small:
      return 'Small';
    case GalleryGridSize.medium:
      return 'Medium';
    case GalleryGridSize.large:
      return 'Large';
  }
}

GridSizeValue gridSizeValueFromLabel(String label) {
  switch (label) {
    case 'Small':
      return GridSizeValue.small;
    case 'Large':
      return GridSizeValue.large;
    default:
      return GridSizeValue.medium;
  }
}