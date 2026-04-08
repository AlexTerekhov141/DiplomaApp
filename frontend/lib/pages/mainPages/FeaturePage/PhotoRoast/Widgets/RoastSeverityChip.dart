import 'package:flutter/material.dart';

import '../../../../../models/PhotoRoastModels/RoastIssue.dart';


class RoastSeverityChip extends StatelessWidget {
  const RoastSeverityChip({
    super.key,
    required this.severity,
  });

  final RoastSeverity severity;

  @override
  Widget build(BuildContext context) {
    switch (severity) {
      case RoastSeverity.high:
        return const Chip(
          label: Text('High'),
          backgroundColor: Color(0xFFFFE5E5),
        );
      case RoastSeverity.medium:
        return const Chip(
          label: Text('Medium'),
          backgroundColor: Color(0xFFFFF3E0),
        );
      case RoastSeverity.low:
        return const Chip(
          label: Text('Low'),
          backgroundColor: Color(0xFFE8F5E9),
        );
    }
  }
}