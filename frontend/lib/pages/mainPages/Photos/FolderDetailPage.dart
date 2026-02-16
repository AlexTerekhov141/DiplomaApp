import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:flutter/material.dart';
import '../../../models/Folders/Folder.dart';

@RoutePage()
class FolderDetailsPage extends StatelessWidget {
  const FolderDetailsPage({super.key, required this.folder});
  final Folder folder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folder.name)),
      body: ResponsiveFrame(
        maxWidth: 800,
        child: Center(child: Text('${folder.id}')),
      ),
    );
  }
}
