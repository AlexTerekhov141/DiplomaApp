import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'ForegroundTaskRepository.dart';

@pragma('vm:entry-point')
void startPhotoProcessingForegroundTask() {
  FlutterForegroundTask.setTaskHandler(PhotoProcessingTaskHandler());
}

class PhotoProcessingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

class ForegroundTaskRepositoryImpl implements ForegroundTaskRepository {
  static const int _serviceId = 731;
  static const String _channelId = 'photo_processing_channel';
  static const String _channelName = 'Photo processing';
  static const String _channelDescription =
      'Shows progress while photos are categorized in the background.';

  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: _channelDescription,
        onlyAlertOnce: true,
        showBadge: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
        allowAutoRestart: true,
        stopWithTask: false,
      ),
    );

    _isInitialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();

    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  @override
  Future<void> startProcessingService() async {
    await init();
    await requestPermissions();

    if (await FlutterForegroundTask.isRunningService) {
      final ServiceRequestResult result =
          await FlutterForegroundTask.updateService(
        notificationTitle: 'Categorizing photos',
        notificationText: 'Preparing local processing...',
        callback: startPhotoProcessingForegroundTask,
      );
      _throwIfFailed(result);
      return;
    }

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      serviceTypes: const <ForegroundServiceTypes>[
        ForegroundServiceTypes.dataSync,
      ],
      notificationTitle: 'Categorizing photos',
      notificationText: 'Preparing local processing...',
      notificationInitialRoute: '/',
      callback: startPhotoProcessingForegroundTask,
    );
    _throwIfFailed(result);
  }

  @override
  Future<void> updateProgress(int processed, int total) async {
    await init();

    if (!await FlutterForegroundTask.isRunningService) {
      return;
    }

    final int safeProcessed = processed < 0 ? 0 : processed;
    final int safeTotal = total < 0 ? 0 : total;
    final String progressText = safeTotal > 0
        ? '$safeProcessed of $safeTotal photos processed'
        : '$safeProcessed photos processed';

    final ServiceRequestResult result =
        await FlutterForegroundTask.updateService(
      notificationTitle: 'Categorizing photos',
      notificationText: progressText,
      callback: startPhotoProcessingForegroundTask,
    );
    _throwIfFailed(result);
  }

  @override
  Future<void> stopProcessingService() async {
    await init();

    if (!await FlutterForegroundTask.isRunningService) {
      return;
    }

    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();
    _throwIfFailed(result);
  }

  void _throwIfFailed(ServiceRequestResult result) {
    if (result is ServiceRequestFailure) {
      throw StateError('Foreground task failed: ${result.error}');
    }
  }
}
