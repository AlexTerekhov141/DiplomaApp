
abstract class Notificationsrepository {
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> showProcessingStarted();
  Future<void> showProcessingProgress(int processed, int total);
  Future<void> showProcessingPaused(int processed, int total);
  Future<void> showProcessingCompleted(int total);
  Future<void> cancelProcessingNotification();
}