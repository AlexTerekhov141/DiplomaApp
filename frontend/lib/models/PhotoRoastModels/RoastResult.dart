import 'RoastIssue.dart';
import 'RoastMetrics.dart';

class RoastResult {
  const RoastResult({
    required this.score,
    required this.issues,
    required this.metrics,
  });

  final int score;
  final List<RoastIssue> issues;
  final RoastMetrics metrics;
}
