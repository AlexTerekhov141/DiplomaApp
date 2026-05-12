import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../bloc/tagsbloc/bloc.dart';
import '../../../../bloc/tagsbloc/event.dart';
import '../../../../models/Folders/Folder.dart';
import '../../../../repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';
import 'Widgets/FolderDetailsView.dart';


@RoutePage()
class FolderDetailsPage extends StatelessWidget {
  const FolderDetailsPage({
    super.key,
    required this.folder,
  });

  final Folder folder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TagsBloc>(
      create: (_) => TagsBloc(
        repository: GetIt.I<ProccessingRouterRepository>(),
      )..add(LoadFolderPhotos(folderId: folder.id)),
      child: FolderDetailsView(folder: folder),
    );
  }
}