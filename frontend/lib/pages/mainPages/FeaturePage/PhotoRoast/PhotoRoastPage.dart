import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import 'Widgets/PhotoRoastView.dart';



@RoutePage()
class PhotoRoastPage extends StatefulWidget {
  const PhotoRoastPage({super.key});

  @override
  State<PhotoRoastPage> createState() => _PhotoRoastPageState();
}

class _PhotoRoastPageState extends State<PhotoRoastPage> {
  bool _showIssues = true;

  void _toggleIssues() {
    setState(() {
      _showIssues = !_showIssues;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoRoastView(
        showIssues: _showIssues,
        onToggleIssues: _toggleIssues,
      ),
    );
  }
}