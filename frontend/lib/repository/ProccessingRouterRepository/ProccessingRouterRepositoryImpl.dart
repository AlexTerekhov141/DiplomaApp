import 'package:categorize_app/models/Processing_mode.dart';
import 'package:categorize_app/repository/PhotosRepository/PhotosRepository.dart';
import 'package:categorize_app/repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';

import '../AppSettingsRepository/AppSettingsRepository.dart';

class ProcessingRouterRepositoryImpl extends ProccessingRouterRepository {
  ProcessingRouterRepositoryImpl({
    required this.appSettings,
    required this.onlineRepository,
    required this.offlineRepository,
  });

  final AppSettingsRepository appSettings;
  final PhotosRepository onlineRepository;
  final PhotosRepository offlineRepository;

  @override
  Future<ProcessingMode> getProcessingMode() async {
    return appSettings.getProcessingMode();
  }

  @override
  Future<bool> isOfflineMode() async {
    final ProcessingMode mode = await appSettings.getProcessingMode();
    return mode == ProcessingMode.offline;
  }

  @override
  Future<PhotosRepository> changeMode() async {
    final ProcessingMode mode = await getProcessingMode();
    if(mode == ProcessingMode.online){
      return onlineRepository;
    }else if(mode == ProcessingMode.offline){
      return offlineRepository;
    }
    return offlineRepository;
  }
}
