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

import '../repository/AuthRepository/AuthRepository.dart';
import '../repository/FolderTagsRepository/FolderTagsRepository.dart';
import '../repository/PhotoRoastRepository/PhotoRoastRepository.dart';
import '../repository/PhotosRepository/PhotosRepository.dart';

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
            photosRepository: GetIt.I<PhotosRepository>(),
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
            final AuthBloc authBloc = AuthBloc(
              authRepository: GetIt.I<AuthRepository>(),
            );
            authBloc.add(AuthStarted());
            return authBloc;
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
      ],
      child: child,
    );
  }
}