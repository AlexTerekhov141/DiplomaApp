import 'package:auto_route/annotations.dart';
import 'package:categorize_app/constants/AppConstantsModels/Features.dart';
import 'package:flutter/material.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import 'Widgets/FeatureHubGrid.dart';


@RoutePage()
class FeatureHubPage extends StatefulWidget {
  const FeatureHubPage({super.key});

  @override
  State<FeatureHubPage> createState() => _FeatureHubPageState();
}

class _FeatureHubPageState extends State<FeatureHubPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: ResponsiveFrame(
        maxWidth: 900,
        child: FeatureHubGrid(
          items: features,
        ),
      ),
    );
  }
}