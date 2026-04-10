import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/pages/mainPages/Photos/Gallery/Widgets/GalleryPhotoTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/PhotosBloc/photosbloc.dart';

@RoutePage()
class TrashPage extends StatefulWidget{
  const TrashPage({super.key});

  @override
  State<StatefulWidget> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage>{

  @override
  void initState() {
    super.initState();
    context.read<PhotosBloc>().add(LoadTrashEvent());
    context.read<PhotosBloc>().add(PhotosLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Trash'),
        ),
        body: ResponsiveFrame(
            maxWidth: 1100,
            child: BlocBuilder<PhotosBloc, PhotosState>(
                builder: (BuildContext context, PhotosState state) {
                  if(state.isLoading){
                    return const CircularProgressIndicator();
                  }
                  if(state.photos.isEmpty){
                    return const Center(child: Text('Empty'));
                  }
                  return GridView.builder(
                      itemCount: state.trashedPhotos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2
                      ),
                      itemBuilder: (_, int index) => GalleryPhotoTile(photo: state.trashedPhotos[index],isInTrash: true,)
                  );
                }
            ))

    );

  }

}