import '../../models/Photo.dart';
import '../../models/PhotoRoastModels/QualityPhotoGroup.dart';
import '../PhotosRepository/PhotosRepository.dart';
import 'PhotoRoastRepository.dart';

class PhotoRoastRepositoryImpl implements PhotoRoastRepository {
  PhotoRoastRepositoryImpl({
    required this.photosRepository,
  });

  final PhotosRepository photosRepository;

  @override
  Future<List<QualityPhotoGroup>> getQualityGroups() async {
    final List<Map<String, dynamic>> rawPhotos = await photosRepository.getPhotos(
      isProcessed: true,
      forceRefresh: true,
    );

    final List<Photo> photos = rawPhotos.map(Photo.fromJson).toList()
      ..sort(
        (Photo a, Photo b) => b.qualityScore.compareTo(a.qualityScore),
      );

    return <QualityPhotoGroup>[
      QualityPhotoGroup(
        level: PhotoQualityLevel.high,
        title: 'High quality',
        description: 'Best photos by backend quality score',
        photos: photos
            .where((Photo photo) => photo.qualityScore >= 0.75)
            .toList(),
      ),
      QualityPhotoGroup(
        level: PhotoQualityLevel.middle,
        title: 'Middle quality',
        description: 'Usable photos with average score',
        photos: photos
            .where(
              (Photo photo) =>
                  photo.qualityScore >= 0.45 && photo.qualityScore < 0.75,
            )
            .toList(),
      ),
      QualityPhotoGroup(
        level: PhotoQualityLevel.low,
        title: 'Low quality',
        description: 'Photos with the weakest backend score',
        photos: photos
            .where((Photo photo) => photo.qualityScore < 0.45)
            .toList(),
      ),
    ];
  }
}
