import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../../bloc/CleanupBloc/cleanupbloc.dart';
import '../../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../../models/CleanUp/CleanupSuggestionGroup.dart';

@RoutePage()
class SuggestedtrashdetailPage extends StatefulWidget {
  const SuggestedtrashdetailPage({super.key, this.group});

  final CleanupSuggestionGroup? group;

  @override
  State<SuggestedtrashdetailPage> createState() => _SuggestedtrashdetailPageState();
}

class _SuggestedtrashdetailPageState extends State<SuggestedtrashdetailPage> {
  @override
  void initState() {
    super.initState();
    final CleanupSuggestionGroup? group = widget.group;
    if (group != null) {
      context.read<CleanupBloc>().add(LoadCleanupSuggestionsByType(group.type));
    }
  }

  @override
  Widget build(BuildContext context) {
    final CleanupSuggestionGroup? group = widget.group;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.title ?? 'Suggested trash'),
      ),
      body: BlocBuilder<CleanupBloc, CleanupState>(
        builder: (BuildContext context, CleanupState state) {
          if (group == null) {
            return const Center(
              child: Text('No cleanup group selected'),
            );
          }

          if (state.isLoading && state.selectedType == group.type) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<CleanupSuggestion> suggestions = state.suggestions
              .where((CleanupSuggestion suggestion) =>
                  suggestion.type == group.type)
              .toList();

          if (suggestions.isEmpty) {
            return const Center(
              child: Text('No photos found'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: suggestions.length,
            itemBuilder: (BuildContext context, int index) {
              return _CleanupSuggestionPhotoTile(
                suggestion: suggestions[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _CleanupSuggestionPhotoTile extends StatelessWidget {
  const _CleanupSuggestionPhotoTile({
    required this.suggestion,
  });

  final CleanupSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(suggestion.assetId),
      builder: (
        BuildContext context,
        AsyncSnapshot<AssetEntity?> snapshot,
      ) {
        final AssetEntity? asset = snapshot.data;
        if (asset == null) {
          return const ColoredBox(
            color: Colors.black12,
            child: Center(
              child: Icon(Icons.image_not_supported_outlined),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AssetEntityImage(
            asset,
            fit: BoxFit.cover,
            isOriginal: false,
          ),
        );
      },
    );
  }
}
