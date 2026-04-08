import 'package:categorize_app/pages/mainPages/FeaturePage/Chat/Widgets/FeatureTile.dart';
import 'package:flutter/material.dart';

import '../../../../../models/Features/Feature.dart';


class FeatureHubGrid extends StatelessWidget {
  const FeatureHubGrid({
    super.key,
    required this.items,
  });

  final List<Feature> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (BuildContext context, int index) {
        return FeatureTile(
          feature: items[index],
        );
      },
    );
  }
}