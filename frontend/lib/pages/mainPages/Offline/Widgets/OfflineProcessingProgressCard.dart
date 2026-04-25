import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';

class OfflineProcessingProgressCard extends StatelessWidget {
  const OfflineProcessingProgressCard({
    super.key,
    required this.processed,
    required this.total,
    required this.pending,
    required this.progress,
    required this.isPaused,
    required this.isDone,
  });

  final int processed;
  final int total;
  final int pending;
  final double? progress;
  final bool isPaused;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final String title = total > 0 ? '$processed / $total' : 'Preparing...';
    final String subtitle = isDone ? 'All photos processed' : isPaused ? 'Paused with $pending photos left' : '$pending photos remaining';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Base.c50,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F1F2A22),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                value: isDone ? 1 : progress,
                strokeWidth: 7,
                backgroundColor: Base.c100,
              ),
            ),
            const SizedBox(height: 20),
            Text(title),
            const SizedBox(height: 6),
            Text(subtitle,),
          ],
        ),
      ),
    );
  }
}
