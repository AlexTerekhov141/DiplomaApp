import '../../models/PhotoRoastModels/QualityPhotoGroup.dart';

abstract class PhotoRoastRepository {
  Future<List<QualityPhotoGroup>> getQualityGroups();
}
