abstract class ForegroundTaskRepository {
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> startProcessingService();
  Future<void> updateProgress(int processed, int total);
  Future<void> stopProcessingService();
}
