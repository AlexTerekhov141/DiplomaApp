import 'package:categorize_app/repository/NotificationsRepository/NotificationsRepository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsRepositoryImpl implements Notificationsrepository{

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> cancelProcessingNotification() async {
    await _plugin.cancel(1);
  }

  @override
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'Photo_proccessing',
      'Photo_proccessing',
      description: 'Proggress',
      importance: Importance.low,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  }

  @override
  Future<void> requestPermissions() async {
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<void> showProcessingCompleted(int total) async {
    await _plugin.show(
      1,
      'Photo categorization completed',
      '$total photos processed',
      _defaultDetails(),
    );
  }

  @override
  Future<void> showProcessingPaused(int processed, int total) async {
    await _plugin.show(
      1,
      'Photo categorization paused',
      'Processed $processed of $total photos',
      _defaultDetails(),
    );
  }

  @override
  Future<void> showProcessingProgress(int processed, int total) async {
    await _plugin.show(
      1,
      'Photo categorization',
      'Processed $processed of $total photos',
      _processingDetails(
        progress: processed,
        maxProgress: total,
        showProgress: total > 0,
      ),
    );
  }

  @override
  Future<void> showProcessingStarted() async {
    await _plugin.show(
      1,
      'Photo categorization',
      'Starting local processing...',
      _processingDetails(),
    );
  }

  NotificationDetails _processingDetails({int progress = 0, int maxProgress = 0, bool showProgress = false,}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'Proccessing',
        'Proccessing',
        channelDescription: 'Proggress',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showProgress: showProgress,
        maxProgress: maxProgress,
        progress: progress,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  NotificationDetails _defaultDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'Proccessing',
        'Proccessing',
        channelDescription: 'Proggress',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        ongoing: false,
        autoCancel: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
