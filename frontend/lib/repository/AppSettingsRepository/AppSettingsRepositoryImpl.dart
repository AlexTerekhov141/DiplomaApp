import 'package:categorize_app/models/Processing_mode.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({required this.storage});
  static const String _modeKey = 'modekeyv5';
  static const String _choiceKey = 'processing_mode_choice_v6';
  final FlutterSecureStorage storage;

  @override
  Future<ProcessingMode> getProcessingMode() async {
    final String? mode = await storage.read(key: _modeKey);
    if (mode == null) {
      return ProcessingMode.online;
    } else if (mode == ProcessingMode.offline.name) {
      return ProcessingMode.offline;
    }
    return ProcessingMode.online;
  }

  @override
  Future<bool> hasProcessingModeChoice() async {
    final String? hasChoice = await storage.read(key: _choiceKey);
    if (hasChoice == 'true') {
      return true;
    }

    final String? savedMode = await storage.read(key: _modeKey);
    return savedMode == ProcessingMode.online.name ||
        savedMode == ProcessingMode.offline.name;
  }

  @override
  Future<void> setProcessingMode(ProcessingMode mode) async {
    await storage.write(key: _modeKey, value: mode.name);
    await storage.write(key: _choiceKey, value: 'true');
  }
}
