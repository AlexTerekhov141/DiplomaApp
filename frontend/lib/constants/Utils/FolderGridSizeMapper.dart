import '../../../bloc/themebloc/states.dart';

int applyFolderGridSize(int baseCount, GalleryGridSize gridSize) {
  switch (gridSize) {
    case GalleryGridSize.small:
      return baseCount + 1;
    case GalleryGridSize.medium:
      return baseCount;
    case GalleryGridSize.large:
      return baseCount > 2 ? baseCount - 1 : 2;
  }
}