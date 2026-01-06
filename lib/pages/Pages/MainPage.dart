import 'package:categorize_app/Widgets/AppAppBar.dart';
import 'package:categorize_app/Widgets/BottomBar.dart';
import 'package:categorize_app/pages/Pages/mainPages/GalleryPage.dart';
import 'package:flutter/material.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {

  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const <Widget>[
          GalleryPage(),
          Placeholder(),
          Placeholder(),
        ],
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