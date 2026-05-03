import 'package:categorize_app/models/Processing_mode.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/Keys.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({required this.storage});
  final FlutterSecureStorage storage;

  @override
  Future<ProcessingMode> getProcessingMode() async {
    final String? mode = await storage.read(key: modeKey);
    if (mode == null) {
      return ProcessingMode.online;
    } else if (mode == ProcessingMode.offline.name) {
      return ProcessingMode.offline;
    }
    return ProcessingMode.online;
  }

  @override
  Future<bool> hasProcessingModeChoice() async {
    final String? hasChoice = await storage.read(key: choiceKey);
    if (hasChoice == 'true') {
      return true;
    }

    final String? savedMode = await storage.read(key: modeKey);
    return savedMode == ProcessingMode.online.name ||
        savedMode == ProcessingMode.offline.name;
  }

  @override
  Future<void> setProcessingMode(ProcessingMode mode) async {
    await storage.write(key: modeKey, value: mode.name);
    await storage.write(key: choiceKey, value: 'true');
  }
}
