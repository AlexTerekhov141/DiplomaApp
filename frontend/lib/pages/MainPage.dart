import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/AppAppBar.dart';
import 'package:categorize_app/Widgets/BottomBar.dart';
import 'package:categorize_app/bloc/PhotosBloc/photosbloc.dart';
import 'package:categorize_app/pages/mainPages/FeaturePage/Chat/ChatPage.dart';
import 'package:categorize_app/pages/mainPages/Photos/Folders/FoldersPage.dart';
import 'package:categorize_app/pages/mainPages/Photos/Gallery/GalleryPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AppPage extends StatefulWidget {
  const AppPage({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<PhotosBloc>().add(PhotosLoadEvent());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const <Widget>[GalleryPage(), FoldersPage(), FeatureHubPage()],
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
