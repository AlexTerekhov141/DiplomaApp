import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepository.dart';
import 'package:categorize_app/repository/AppSettingsRepository/AppSettingsRepositoryImpl.dart';
import 'package:categorize_app/repository/PhotosRepository/OfflinePhotosRepositoryImpl.dart';
import 'package:categorize_app/repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';
import 'package:categorize_app/repository/ProccessingRouterRepository/ProccessingRouterRepositoryImpl.dart';
import 'package:categorize_app/repository/TFliteRepository/TFliteRepository.dart';
import 'package:categorize_app/repository/TFliteRepository/TFliteRepositoryImpl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../bloc/EnchanceBloc/bloc.dart';
import '../../models/EnchanceProcessor.dart';
import '../../models/Saver.dart';
import '../../repository/AuthRepository/AuthRepository.dart';
import '../../repository/AuthRepository/AuthRepositoryImpl.dart';
import '../../repository/FolderTagsRepository/FolderTagsRepository.dart';
import '../../repository/FolderTagsRepository/FolderTagsRepositoryImpl.dart';
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
      () => AppSettingsRepositoryImpl(storage: getIt<FlutterSecureStorage>())
  );

  getIt.registerLazySingleton<TFliteRepository>(
          () => TFliteRepositoryImpl()
  );

  getIt.registerLazySingleton<PhotosRepository>(
        () => PhotosRepositoryImpl(dio: getIt<Dio>(), storage: getIt<FlutterSecureStorage>(),
    ),
    instanceName: 'online',
  );

  getIt.registerLazySingleton<PhotosRepository>(
        () => Offlinephotosrepositoryimpl(storage: getIt<FlutterSecureStorage>(), tflite: getIt<TFliteRepository>(),),
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

  getIt.registerLazySingleton<EnchanceProcessor>(() => enhanceProcessor);
  getIt.registerLazySingleton<EnchanceSaver>(() => enhanceSaver);
}
