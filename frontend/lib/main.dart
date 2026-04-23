import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'Main/AppProviders.dart';
import 'Main/app.dart';
import 'constants/DI/ServiceLocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  final Talker talker = GetIt.I<Talker>();

  FlutterError.onError = (FlutterErrorDetails details) {
    talker.handle(details.exception, details.stack);
  };

  Bloc.observer = TalkerBlocObserver();

  await runZonedGuarded(
        () async {
      talker.debug('started');
      runApp(
        const AppProviders(
          child: MyApp(),
        ),
      );
    },
        (Object error, StackTrace stack) {
      talker.handle(error, stack);
    },
  );
}