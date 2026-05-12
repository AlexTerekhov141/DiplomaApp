import '../Photo.dart';

enum PhotoQualityLevel { high, middle, low }

class QualityPhotoGroup {
  const QualityPhotoGroup({
    required this.level,
    required this.title,
    required this.description,
    required this.photos,
  });

  final PhotoQualityLevel level;
  final String title;
  final String description;
  final List<Photo> photos;
}
