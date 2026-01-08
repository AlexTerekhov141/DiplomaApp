import 'dart:async';

import 'package:categorize_app/bloc/PhotosBloc/bloc.dart';
import 'package:categorize_app/bloc/PhotosBloc/events.dart';
import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nested/nested.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'app.dart';

Future<void> main() async {
  final Talker talker = TalkerFlutter.init();
  GetIt.I.registerSingleton<Talker>(talker);

  FlutterError.onError = (FlutterErrorDetails details) => GetIt.I<Talker>().handle(details.exception, details.stack);

  Bloc.observer = TalkerBlocObserver();
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    GetIt.I<Talker>().debug('started');
    
    runApp(
        MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider(create: (_) => PhotosBloc()..add(PhotosLoadEvent())),
              BlocProvider(create: (_) => ThemeBloc())
            ],
            child: const MyApp())
    );
  }, (Object error, StackTrace stack) {
  GetIt.I<Talker>().handle(error, stack);
  });
}