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

  getIt.registerLazySingleton<PhotosRepository>(
        () => PhotosRepositoryImpl(
      dio: getIt<Dio>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<FolderTagsRepository>(
        () => FolderTagsRepositoryImpl(getIt<PhotosRepository>()),
  );

  getIt.registerLazySingleton<EnchanceProcessor>(() => enhanceProcessor);
  getIt.registerLazySingleton<EnchanceSaver>(() => enhanceSaver);
}