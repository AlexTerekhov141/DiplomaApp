import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import 'Data/AboutInfo.dart';
import 'Widgets/AboutAppCard.dart';
import 'Widgets/AboutInfoCard.dart';


@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ResponsiveFrame(
        maxWidth: 760,
        child: ListView(
          children: const <Widget>[
            AboutAppCard(
              title: AboutInfo.appName,
              description: AboutInfo.description,
            ),
            SizedBox(height: 12),
            AboutInfoCard(
              version: AboutInfo.version,
              lastUpdate: AboutInfo.lastUpdate,
              info: AboutInfo.info,
            ),
          ],
        ),
      ),
    );
  }
}