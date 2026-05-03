import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/PhotoRoastBloc/photoroastbloc.dart';
import 'Widgets/PhotoRoastView.dart';



@RoutePage()
class PhotoRoastPage extends StatefulWidget {
  const PhotoRoastPage({super.key});

  @override
  State<PhotoRoastPage> createState() => _PhotoRoastPageState();
}

class _PhotoRoastPageState extends State<PhotoRoastPage> {
  @override
  void initState() {
    super.initState();
    context.read<PhotoRoastBloc>().add(
          const PhotoRoastQualityGroupsRequested(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PhotoRoastView(),
    );
  }
}
