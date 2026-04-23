import 'package:categorize_app/models/Processing_mode.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({required this.storage});
  static const String _modeKey = 'modekeyv1';
  final FlutterSecureStorage storage;

  @override
  Future<ProcessingMode> getProcessingMode() async {
    final String? mode = await storage.read(key: _modeKey);
    if(mode == null){
      return ProcessingMode.online;
    }else if(mode == ProcessingMode.offline.name){
      return ProcessingMode.offline;
    }
    return ProcessingMode.online;
  }

  @override
  Future<void> setProcessingMode(ProcessingMode mode) async {
    await storage.write(key: _modeKey, value: mode.name);
  }

}
