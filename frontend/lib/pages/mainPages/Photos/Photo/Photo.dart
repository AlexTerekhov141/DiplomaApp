import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:categorize_app/bloc/PhotosBloc/bloc.dart';
import 'package:categorize_app/bloc/PhotosBloc/events.dart';
import 'package:categorize_app/bloc/PhotosBloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../models/Photo.dart';

@RoutePage()
class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({super.key, required this.photo});
  final AssetEntity photo;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late final PageController _pageController;
  late final List<AssetEntity> _viewerPhotos;
  int _currentIndex = 0;
  double _verticalDragOffset = 0;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    final PhotosState state = context.read<PhotosBloc>().state;
    _viewerPhotos = _resolveViewerPhotos(state);
    _currentIndex = _initialIndex(_viewerPhotos, widget.photo.id);
    _pageController = PageController(initialPage: _currentIndex);
  }

  List<AssetEntity> _resolveViewerPhotos(PhotosState state) {
    if (state.trashedIds.contains(widget.photo.id)) {
      if (state.trashedPhotos.isNotEmpty) {
        return state.trashedPhotos;
      }
    } else if (state.activePhotos.isNotEmpty) {
      return state.activePhotos;
    }
    return <AssetEntity>[widget.photo];
  }

  int _initialIndex(List<AssetEntity> photos, String selectedId) {
    final int index = photos.indexWhere((AssetEntity p) => p.id == selectedId);
    return index >= 0 ? index : 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isClosing) {
      return;
    }
    setState(() {
      _verticalDragOffset += details.delta.dy;
    });
  }

  Future<void> _onVerticalDragEnd(DragEndDetails details) async {
    if (_isClosing) {
      return;
    }

    final double velocity = details.velocity.pixelsPerSecond.dy.abs();
    final bool shouldClose = _verticalDragOffset.abs() > 120 || velocity > 900;

    if (!shouldClose) {
      setState(() {
        _verticalDragOffset = 0;
      });
      return;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double direction = _verticalDragOffset == 0
        ? (details.velocity.pixelsPerSecond.dy >= 0 ? 1 : -1)
        : _verticalDragOffset.sign;

    setState(() {
      _isClosing = true;
      _verticalDragOffset = direction * screenHeight;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AssetEntity currentPhoto = _viewerPhotos[_currentIndex];
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dragProgress =
    (_verticalDragOffset.abs() / (screenHeight * 0.8)).clamp(0.0, 1.0);
    final double scale = 1 - (dragProgress * 0.12);
    final double bgOpacity = 1 - (dragProgress * 0.55);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          _PhotoFavourite(favoriteId: currentPhoto.id),
        ],
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: _isClosing ? 160 : 220),
        curve: Curves.easeOutCubic,
        color: Colors.black.withOpacity(bgOpacity),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Transform.translate(
            offset: Offset(0, _verticalDragOffset),
            child: Transform.scale(
              scale: scale,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _viewerPhotos.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (_, int index) {
                  final AssetEntity photo = _viewerPhotos[index];
                  return PhotoView(
                    imageProvider: AssetEntityImageProvider(
                      photo,
                      isOriginal: true,
                    ),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NetworkPhotoViewerPage extends StatefulWidget {
  const NetworkPhotoViewerPage({
    super.key,
    required this.photo,
    this.photos,
    this.initialIndex,
  });
  final Photo photo;
  final List<Photo>? photos;
  final int? initialIndex;

  @override
  State<NetworkPhotoViewerPage> createState() => _NetworkPhotoViewerPageState();
}

class _NetworkPhotoViewerPageState extends State<NetworkPhotoViewerPage> {
  late final List<Photo> _viewerPhotos;
  late final PageController _pageController;
  int _currentIndex = 0;
  double _verticalDragOffset = 0;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _viewerPhotos = (widget.photos != null && widget.photos!.isNotEmpty)
        ? widget.photos!
        : <Photo>[widget.photo];
    _currentIndex = _resolveInitialIndex();
    _pageController = PageController(initialPage: _currentIndex);
  }

  int _resolveInitialIndex() {
    if (widget.initialIndex != null) {
      final int index = widget.initialIndex!;
      if (index >= 0 && index < _viewerPhotos.length) {
        return index;
      }
    }

    final int byId = _viewerPhotos.indexWhere(
          (Photo p) => p.id == widget.photo.id,
    );
    return byId >= 0 ? byId : 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isClosing) {
      return;
    }
    setState(() {
      _verticalDragOffset += details.delta.dy;
    });
  }

  Future<void> _onVerticalDragEnd(DragEndDetails details) async {
    if (_isClosing) {
      return;
    }

    final double velocity = details.velocity.pixelsPerSecond.dy.abs();
    final bool shouldClose = _verticalDragOffset.abs() > 120 || velocity > 900;

    if (!shouldClose) {
      setState(() {
        _verticalDragOffset = 0;
      });
      return;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double direction = _verticalDragOffset == 0
        ? (details.velocity.pixelsPerSecond.dy >= 0 ? 1 : -1)
        : _verticalDragOffset.sign;

    setState(() {
      _isClosing = true;
      _verticalDragOffset = direction * screenHeight;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Photo currentPhoto = _viewerPhotos[_currentIndex];
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dragProgress =
    (_verticalDragOffset.abs() / (screenHeight * 0.8)).clamp(0.0, 1.0);
    final double scale = 1 - (dragProgress * 0.12);
    final double bgOpacity = 1 - (dragProgress * 0.55);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          _PhotoFavourite(favoriteId: currentPhoto.id.toString()),
        ],
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: _isClosing ? 160 : 220),
        curve: Curves.easeOutCubic,
        color: Colors.black.withOpacity(bgOpacity),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Transform.translate(
            offset: Offset(0, _verticalDragOffset),
            child: Transform.scale(
              scale: scale,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _viewerPhotos.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (_, int index) {
                        final Photo pagePhoto = _viewerPhotos[index];
                        return PhotoView(
                          imageProvider: CachedNetworkImageProvider(
                            pagePhoto.image,
                            cacheKey: 'photo_${pagePhoto.id}',
                          ),
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentPhoto.tags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, int index) {
                        return Chip(label: Text(currentPhoto.tags[index]));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoFavourite extends StatelessWidget {
  const _PhotoFavourite({required this.favoriteId});
  final String favoriteId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PhotosBloc, PhotosState, bool>(
      selector: (PhotosState state) => state.favoriteIds.contains(favoriteId),
      builder: (BuildContext context, bool isFavorite) {
        return IconButton(
          onPressed: () {
            context.read<PhotosBloc>().add(ToggleFavoriteEvent(favoriteId));
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.white,
          ),
        );
      },
    );
  }
}