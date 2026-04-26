import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepositoryImpl.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupAnalyzer/DuplicateAnalyzer.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupAnalyzer/ImageQualityAnalyzer.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupAnalyzer/MetadataCleanupAnalyzer.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupAnalyzer/OcrCleanupAnalyzer.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupRepository.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupStorage/CleanupStorage.dart';
import 'package:categorize_app/repository/ForegroundTaskRepository/ForegroundTaskRepository.dart';
import 'package:categorize_app/repository/ForegroundTaskRepository/ForegroundTaskRepositoryImpl.dart';
import 'package:categorize_app/repository/NotificationsRepository/NotificationsRepository.dart';
import 'package:categorize_app/repository/NotificationsRepository/NotificationsRepositoryImpl.dart';
import 'package:categorize_app/repository/PhotosRepository/OfflinePhotosRepositoryImpl.dart';
import 'package:categorize_app/repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';
import 'package:categorize_app/repository/ProccessingRouterRepository/ProccessingRouterRepositoryImpl.dart';
import 'package:categorize_app/repository/TFliteRepository/TFliteRepository.dart';
import 'package:categorize_app/repository/TFliteRepository/TFliteRepositoryImpl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../bloc/EnchanceBloc/bloc.dart';
import '../../models/EnchanceProcessor.dart';
import '../../models/Saver.dart';
import '../../repository/AuthRepository/AuthRepository.dart';
import '../../repository/AuthRepository/AuthRepositoryImpl.dart';
import '../../repository/CleanupRepository/CleanupAnalyzer/CleanupScoreCalculator.dart';
import '../../repository/CleanupRepository/CleanupRepositoryImpl.dart';
import '../../repository/CleanupRepository/CleanupStorage/SqfliteCleanupStorage.dart';
import '../../repository/FolderTagsRepository/FolderTagsRepository.dart';
import '../../repository/FolderTagsRepository/FolderTagsRepositoryImpl.dart';
import '../../repository/OfflinePredictionsStorage/OfflinePredictionsStorage.dart';
import '../../repository/OfflinePredictionsStorage/SqfliteOfflinePredictionsStorage.dart';
import '../../repository/PhotoRoastRepository/PhotoRoastRepository.dart';
import '../../repository/PhotoRoastRepository/PhotoRoastRepositoryImpl.dart';
import '../../repository/PhotosRepository/PhotosRepository.dart';
import '../../repository/PhotosRepository/PhotosRepositoryImpl.dart';
import '../Network/DioFactory.dart';

Future<void> configureDependencies() async {
  final GetIt getIt = GetIt.I;

  final Talker talker = TalkerFlutter.init();
  const FlutterSecureStorage storage = FlutterSecureStorage();
  final Dio dio = createDio();
  final TextRecognizer textRecognizer = TextRecognizer();
  getIt.registerSingleton<Talker>(talker);
  getIt.registerSingleton<FlutterSecureStorage>(storage);
  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<PhotoRoastRepository>(
    () => PhotoRoastRepositoryImpl(),
  );

  getIt.registerLazySingleton<AppSettingsRepository>(
    () => AppSettingsRepositoryImpl(storage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TFliteRepository>(
    () => TFliteRepositoryImpl(),
  );

  getIt.registerLazySingleton<OfflinePredictionsStorage>(
    () => SqfliteOfflinePredictionsStorage(),
  );

  getIt.registerLazySingleton<PhotosRepository>(
    () => PhotosRepositoryImpl(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
    instanceName: 'online',
  );

  getIt.registerLazySingleton<PhotosRepository>(
    () => Offlinephotosrepositoryimpl(
      storage: getIt<FlutterSecureStorage>(),
      tflite: getIt<TFliteRepository>(),
      predictionsStorage: getIt<OfflinePredictionsStorage>(),
    ),
    instanceName: 'offline',
  );

  getIt.registerLazySingleton<PhotosRepository>(
    () => getIt<PhotosRepository>(instanceName: 'online'),
  );

  getIt.registerLazySingleton<FolderTagsRepository>(
    () => FolderTagsRepositoryImpl(getIt<ProccessingRouterRepository>()),
  );

  getIt.registerLazySingleton<ProccessingRouterRepository>(
    () => ProcessingRouterRepositoryImpl(
      appSettings: getIt<AppSettingsRepository>(),
      onlineRepository: getIt<PhotosRepository>(instanceName: 'online'),
      offlineRepository: getIt<PhotosRepository>(instanceName: 'offline'),
    ),
  );

  getIt.registerLazySingleton<Notificationsrepository>(
    () => NotificationsRepositoryImpl(),
  );

  getIt.registerLazySingleton<ForegroundTaskRepository>(
    () => ForegroundTaskRepositoryImpl(),
  );

  getIt.registerLazySingleton<EnchanceProcessor>(() => enhanceProcessor);
  getIt.registerLazySingleton<EnchanceSaver>(() => enhanceSaver);

  getIt.registerLazySingleton<CleanupStorage>(
          () => SqfliteCleanupStorage()
  );
  getIt.registerLazySingleton<MetadataCleanupAnalyzer>(
      () => MetadataCleanupAnalyzer()
  );
  getIt.registerLazySingleton<ImageQualityAnalyzer>(
      () => ImageQualityAnalyzer()
  );
  getIt.registerLazySingleton<DuplicateAnalyzer>(
      () => DuplicateAnalyzer()
  );
  getIt.registerLazySingleton<OcrCleanupAnalyzer>(
      () => OcrCleanupAnalyzer(textRecognizer: textRecognizer)
  );
  getIt.registerLazySingleton<CleanupScoreCalculator>(
      () => CleanupScoreCalculator()
  );
  getIt.registerLazySingleton<CleanupRepository>(
      () => CleanupRepositoryImpl(
          storage: getIt<CleanupStorage>(),
          metadataAnalyzer: getIt<MetadataCleanupAnalyzer>(),
          imageQualityAnalyzer: getIt<ImageQualityAnalyzer>(),
          duplicateAnalyzer: getIt<DuplicateAnalyzer>(),
          ocrAnalyzer: getIt<OcrCleanupAnalyzer>(),
          scoreCalculator: getIt<CleanupScoreCalculator>(),
          enableMetadataAnalyzer: true,
          enableImageQualityAnalyzer: true,
          enableDuplicateAnalyzer: false,
          enableOcrAnalyzer: true)
  );
}
