import 'package:flutter/material.dart';

class AboutAppCard extends StatelessWidget {
  const AboutAppCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}