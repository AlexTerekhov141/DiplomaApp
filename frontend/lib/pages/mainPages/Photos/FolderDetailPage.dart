import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/themebloc/bloc.dart';
import 'package:categorize_app/bloc/themebloc/states.dart';
import 'package:categorize_app/models/Folders/Folder.dart';
import 'package:categorize_app/pages/mainPages/Photos/Photo.dart';
import 'package:categorize_app/repository/PhotosRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class FolderDetailsPage extends StatefulWidget {
  const FolderDetailsPage({super.key, required this.folder});
  final Folder folder;

  @override
  State<FolderDetailsPage> createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  late final Future<List<String>> _photosFuture = _loadFolderPhotos();

  Future<List<String>> _loadFolderPhotos() async {
    final PhotosRepository repository = GetIt.I<PhotosRepository>();
    final List<Map<String, dynamic>> photos = await repository.getPhotos();

    final bool isUncategorized = widget.folder.id == 'uncategorized';

    final List<String> urls = <String>[];
    for (final Map<String, dynamic> photo in photos) {
      final dynamic rawCategory = photo['category'];
      final String? categoryId = rawCategory is Map<String, dynamic>
          ? rawCategory['id']?.toString()
          : null;

      if (isUncategorized) {
        if (categoryId == null || categoryId.isEmpty) {
          final String url = (photo['image'] ?? '').toString();
          if (url.isNotEmpty) {
            urls.add(url);
          }
        }
      } else if (categoryId == widget.folder.id) {
        final String url = (photo['image'] ?? '').toString();
        if (url.isNotEmpty) {
          urls.add(url);
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: ResponsiveFrame(
        maxWidth: 1000,
        child: FutureBuilder<List<String>>(
          future: _photosFuture,
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final List<String> photos = snapshot.data ?? <String>[];
            if (photos.isEmpty) {
              return const Center(child: Text('No photos in this folder'));
            }

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int baseCount = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 600
                        ? 3
                        : 2;
                final GalleryGridSize gridSize = context.select(
                  (ThemeBloc bloc) => bloc.state.gridSize,
                );
                final int crossAxisCount = _applyGridSize(baseCount, gridSize);
                return GridView.builder(
                  itemCount: photos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                NetworkPhotoViewerPage(imageUrl: photos[index]),
                          ),
                        );
                      },
                      child: Image.network(
                        photos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Colors.black12,
                          child: Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
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
