import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/pages/mainPages/Photos/Gallery/Widgets/GalleryPhotoTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/PhotosBloc/photosbloc.dart';

@RoutePage()
class FavouritePage extends StatefulWidget{
  const FavouritePage({super.key});

  @override
  State<StatefulWidget> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>{

  @override
  void initState() {
    super.initState();
    context.read<PhotosBloc>().add(LoadFavoritesEvent());
    context.read<PhotosBloc>().add(PhotosLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favourite'),
        ),
        body: ResponsiveFrame(
            maxWidth: 1100,
            child: BlocBuilder<PhotosBloc, PhotosState>(
            builder: (BuildContext context, PhotosState state) {
              if(state.isLoading){
                return const CircularProgressIndicator();
              }
              if(state.photos.isEmpty){
                return const Center(child: Text('No fav photos'));
              }
              return GridView.builder(
                  itemCount: state.favoritePhotos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2
                  ),
                  itemBuilder: (_, int index) => GalleryPhotoTile(photo: state.favoritePhotos[index],)
              );
            }
        ))

    );

  }

}