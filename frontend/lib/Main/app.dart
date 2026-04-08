import 'package:categorize_app/Routes/routegard.dart';
import 'package:categorize_app/Themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../Routes/routes.dart';
import '../bloc/AuthBloc/authbloc.dart';
import '../bloc/FoldersBloc/foldersbloc.dart';
import '../bloc/PhotosBloc/photosbloc.dart';
import '../bloc/themebloc/themebloc.dart';


final RouteGuard authGuard = RouteGuard();
final AppRouter _appRouter = AppRouter(authGuard);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final Themes themes = Themes();
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.isAuthenticated != current.isAuthenticated,
      listener: (BuildContext context, AuthState state) {
        if (state.isAuthenticated) {
          context.read<PhotosBloc>().add(PhotosLoadEvent());
          context.read<FoldersBloc>().add(LoadFolders());
        } else {
          context.read<PhotosBloc>().add(PhotosResetEvent());
          context.read<FoldersBloc>().add(ClearFolders());
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (BuildContext context, ThemeState state) {
          return MaterialApp.router(
            routerConfig: _appRouter.config(
              navigatorObservers: () => <NavigatorObserver>[
                TalkerRouteObserver(GetIt.I<Talker>()),
              ],
            ),
            theme: themes.lightTheme,
            darkTheme: themes.darkTheme,
            themeMode: state.themeMode,
          );
        },
      ),
    );
  }
}
