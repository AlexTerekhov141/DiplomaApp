import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../../bloc/CleanupBloc/cleanupbloc.dart';
import '../../../../models/CleanUp/CleanupSuggestion.dart';
import '../../../../models/CleanUp/CleanupSuggestionGroup.dart';
import '../../Photos/Photo/Photo.dart';

@RoutePage()
class SuggestedtrashdetailPage extends StatefulWidget {
  const SuggestedtrashdetailPage({super.key, this.group});

  final CleanupSuggestionGroup? group;

  @override
  State<SuggestedtrashdetailPage> createState() =>
      _SuggestedtrashdetailPageState();
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
      appBar: AppBar(title: Text(group?.title ?? 'Suggested trash')),
      body: BlocBuilder<CleanupBloc, CleanupState>(
        builder: (BuildContext context, CleanupState state) {
          if (group == null) {
            return const Center(child: Text('No cleanup group selected'));
          }

          if (state.isLoading && state.selectedType == group.type) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<CleanupSuggestion> suggestions = state.suggestions
              .where(
                (CleanupSuggestion suggestion) => suggestion.type == group.type,
              )
              .toList();

          if (suggestions.isEmpty) {
            return const Center(child: Text('No photos found'));
          }

          return FutureBuilder<List<AssetEntity>>(
            future: _loadAssetsForSuggestions(suggestions),
            builder:
                (BuildContext context, AsyncSnapshot<List<AssetEntity>> snapshot,) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<AssetEntity> assets =
                      snapshot.data ?? <AssetEntity>[];
                  if (assets.isEmpty) {
                    return const Center(
                      child: Text('Photos are not available on this device'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: assets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _CleanupSuggestionPhotoTile(
                        asset: assets[index],
                        assets: assets,
                        index: index,
                      );
                    },
                  );
                },
          );
        },
      ),
    );
  }
}

Future<List<AssetEntity>> _loadAssetsForSuggestions(List<CleanupSuggestion> suggestions,) async {
  final List<AssetEntity> assets = <AssetEntity>[];
  for (final CleanupSuggestion suggestion in suggestions) {
    final AssetEntity? asset = await AssetEntity.fromId(suggestion.assetId);
    if (asset != null) {
      assets.add(asset);
    }
  }
  return assets;
}

class _CleanupSuggestionPhotoTile extends StatelessWidget {
  const _CleanupSuggestionPhotoTile({
    required this.asset,
    required this.assets,
    required this.index,
  });

  final AssetEntity asset;
  final List<AssetEntity> assets;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PhotoViewerPage(
                photo: asset,
                photos: assets,
                initialIndex: index,
              ),
            ),
          );
        },
        child: ClipRRect(
          child: AssetEntityImage(asset, fit: BoxFit.cover, isOriginal: false),
        ),
      ),
    );
  }
}
