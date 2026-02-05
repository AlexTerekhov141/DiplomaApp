import 'dart:async';

import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/FoldersBloc/bloc.dart';
import 'package:categorize_app/bloc/FoldersBloc/events.dart';
import 'package:categorize_app/bloc/PhotosBloc/bloc.dart';
import 'package:categorize_app/bloc/PhotosBloc/events.dart';
import 'package:categorize_app/bloc/StatisticsBloc/bloc.dart';
import 'package:categorize_app/bloc/StatisticsBloc/events.dart';
import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:categorize_app/repository/AuthRepository.dart';
import 'package:categorize_app/repository/FolderTagsRepository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:nested/nested.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app.dart';
import 'bloc/AuthBloc/event.dart';

Future<void> main() async {
  final Talker talker = TalkerFlutter.init();
  final Dio dio = Dio();
  const FlutterSecureStorage storage = FlutterSecureStorage();
  GetIt.I.registerSingleton<Talker>(talker);
  GetIt.I.registerSingleton<Dio>(dio);
  GetIt.I.registerSingleton<FlutterSecureStorage>(storage);
  FlutterError.onError = (FlutterErrorDetails details) => GetIt.I<Talker>().handle(details.exception, details.stack);

  dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      )
  );

  Bloc.observer = TalkerBlocObserver();
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    GetIt.I<Talker>().debug('started');

    GetIt.I.registerLazySingleton<AuthRepository>(
          () => AuthRepository(dio: GetIt.I<Dio>(), storage: GetIt.I<FlutterSecureStorage>()),
    );

    runApp(
        MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider(create: (_) => PhotosBloc()..add(PhotosLoadEvent())),
              BlocProvider(create: (_) => ThemeBloc()),
              BlocProvider(create: (_) => FoldersBloc(FolderTagsRepository())..add(LoadFolders())),
              BlocProvider(create: (BuildContext context) => StatisticsBloc(photosBloc: context.read<PhotosBloc>(), foldersBloc: context.read<FoldersBloc>())..add(LoadStatistics())),
              BlocProvider(create: (BuildContext context) {
                  final AuthBloc authBloc = AuthBloc(authRepository: GetIt.I<AuthRepository>());
                  authBloc.add(AuthStarted());
                  return authBloc;
                },
              ),
            ],
            child: const MyApp())
    );
  }, (Object error, StackTrace stack) {
  GetIt.I<Talker>().handle(error, stack);
  });
}