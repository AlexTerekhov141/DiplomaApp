import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/PhotosBloc/bloc.dart';
import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:categorize_app/bloc/themebloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../bloc/PhotosBloc/states.dart';

@RoutePage()
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ResponsiveFrame(
        maxWidth: 1200,
        mobilePadding: EdgeInsets.zero,
        desktopPadding: EdgeInsets.zero,
        child: BlocBuilder<PhotosBloc, PhotosState>(
          builder: (BuildContext context, PhotosState state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int baseCount = constraints.maxWidth >= 1000
                    ? 6
                    : constraints.maxWidth >= 700
                    ? 4
                    : 3;
                final GalleryGridSize gridSize = context.select(
                  (ThemeBloc bloc) => bloc.state.gridSize,
                );
                final int crossAxisCount = _applyGridSize(baseCount, gridSize);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: state.photos.length,
                  itemBuilder: (_, int index) {
                    return GestureDetector(
                      onTap: () {
                        context.router.push(
                          PhotoViewerRoute(photo: state.photos[index]),
                        );
                      },
                      child: AssetEntityImage(
                        state.photos[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

int _applyGridSize(int baseCount, GalleryGridSize gridSize) {
  switch (gridSize) {
    case GalleryGridSize.small:
      return baseCount + 1;
    case GalleryGridSize.medium:
      return baseCount;
    case GalleryGridSize.large:
      return baseCount > 2 ? baseCount - 1 : 2;
  }
}
