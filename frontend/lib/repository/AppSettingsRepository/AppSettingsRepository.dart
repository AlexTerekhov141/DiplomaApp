import '../../models/Processing_mode.dart';

abstract class AppSettingsRepository {
  Future<ProcessingMode> getProcessingMode();
  Future<bool> hasProcessingModeChoice();
  Future<void> setProcessingMode(ProcessingMode mode);
}
