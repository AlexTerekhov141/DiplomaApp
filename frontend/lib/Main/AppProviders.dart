import 'package:categorize_app/bloc/CleanupBloc/cleanupbloc.dart';
import 'package:categorize_app/repository/CleanupRepository/CleanupRepository.dart';
import 'package:categorize_app/repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nested/nested.dart';

import '../bloc/AuthBloc/authbloc.dart';
import '../bloc/EnchanceBloc/enchancebloc.dart';
import '../bloc/FoldersBloc/foldersbloc.dart';
import '../bloc/PhotoRoastBloc/photoroastbloc.dart';
import '../bloc/PhotosBloc/photosbloc.dart';
import '../bloc/StatisticsBloc/statisticsbloc.dart';
import '../bloc/themebloc/themebloc.dart';
import '../repository/AppSettingsRepository/AppSettingsRepository.dart';
import '../repository/AuthRepository/AuthRepository.dart';
import '../repository/FolderTagsRepository/FolderTagsRepository.dart';
import '../repository/ForegroundTaskRepository/ForegroundTaskRepository.dart';
import '../repository/NotificationsRepository/NotificationsRepository.dart';
import '../repository/PhotoRoastRepository/PhotoRoastRepository.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider(
          create: (_) => PhotosBloc(
            repository: GetIt.I<ProccessingRouterRepository>(),
            notifications: GetIt.I<Notificationsrepository>(),
            foregroundTaskRepository: GetIt.I<ForegroundTaskRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => ThemeBloc(
            storage: GetIt.I(),
          )..add(LoadThemeSettingsEvent()),
        ),
        BlocProvider(
          create: (_) => FoldersBloc(
            GetIt.I<FolderTagsRepository>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => StatisticsBloc(
            photosBloc: context.read<PhotosBloc>(),
            foldersBloc: context.read<FoldersBloc>(),
          )..add(LoadStatistics()),
        ),
        BlocProvider(
          create: (_) {
            return AuthBloc(
              authRepository: GetIt.I<AuthRepository>(),
              appSettingsRepository: GetIt.I<AppSettingsRepository>(),
            );
          },
        ),
        BlocProvider(
          create: (_) => EnchanceBloc(
            processor: GetIt.I<EnchanceProcessor>(),
            saver: GetIt.I<EnchanceSaver>(),
          ),
        ),
        BlocProvider(
          create: (_) => PhotoRoastBloc(
            repository: GetIt.I<PhotoRoastRepository>(),
          ),
        ),
        BlocProvider(create: (_) => CleanupBloc(repository: GetIt.I<CleanupRepository>()))
      ],
      child: child,
    );
  }
}
