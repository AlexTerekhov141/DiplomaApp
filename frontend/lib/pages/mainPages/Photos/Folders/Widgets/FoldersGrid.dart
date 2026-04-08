import 'package:flutter/material.dart';

import '../../../../../models/Folders/Folder.dart';
import 'FolderTile.dart';



class FoldersGrid extends StatelessWidget {
  const FoldersGrid({
    super.key,
    required this.folders,
    required this.crossAxisCount,
  });

  final List<Folder> folders;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: folders.length,
      itemBuilder: (_, int index) {
        return FolderTile(folder: folders[index]);
      },
    );
  }
}