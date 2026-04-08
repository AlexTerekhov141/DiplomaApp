import 'package:flutter/material.dart';

class GalleryProcessingCard extends StatelessWidget {
  const GalleryProcessingCard({
    super.key,
    required this.processed,
    required this.total,
    required this.pending,
    required this.progress,
  });

  final int processed;
  final int total;
  final int pending;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Server categorization',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Categorized: $processed / $total   Pending: $pending',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
            ],
          ),
        ),
      ),
    );
  }
}