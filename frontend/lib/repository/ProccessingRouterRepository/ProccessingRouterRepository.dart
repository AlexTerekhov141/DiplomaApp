import 'package:categorize_app/repository/PhotosRepository/PhotosRepository.dart';

import '../../models/Processing_mode.dart';

abstract class ProccessingRouterRepository {
  Future<ProcessingMode> getProcessingMode();

  Future<bool> isOfflineMode();

  Future<PhotosRepository> changeMode();
}
