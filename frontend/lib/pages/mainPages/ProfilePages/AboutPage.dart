import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ResponsiveFrame(
        maxWidth: 760,
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Categorize App', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Categorize App helps you organize photos into folders, '
                      'keep your gallery structured and quickly find moments by tags.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Card(
              elevation: 0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.update_outlined),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.calendar_today_outlined),
                    title: Text('Last update'),
                    subtitle: Text('February 12, 2026'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.policy_outlined),
                    title: Text('Info'),
                    subtitle: Text(
                      'Version, release date, legal links, privacy policy, '
                      'terms of use, licenses and short app mission.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
