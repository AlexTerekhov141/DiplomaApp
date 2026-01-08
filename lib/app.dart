import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'Routes/routes.dart';
import 'bloc/themebloc/states.dart';

final AppRouter _appRouter = AppRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
        builder: (BuildContext context, ThemeState state){
          return MaterialApp.router(
            routerConfig: _appRouter.config(
                navigatorObservers: () => <NavigatorObserver>[
                  TalkerRouteObserver(GetIt.I<Talker>()),
                ]
            ),
            theme: state.themeData,

          );
        }
    );
  }
}
