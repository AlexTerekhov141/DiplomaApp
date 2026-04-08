import 'dart:typed_data';

import '../../models/PhotoRoastModels/RoastModels.dart';


abstract class PhotoRoastRepository {
  Future<RoastMetrics> analyzeMetrics(Uint8List bytes);
  List<RoastIssue> buildIssues(RoastMetrics metrics);
  int calculateScore(RoastMetrics metrics, List<RoastIssue> issues);

  Future<RoastResult> run(Uint8List bytes) async {
    final RoastMetrics metrics = await analyzeMetrics(bytes);
    final List<RoastIssue> issues = buildIssues(metrics);
    final int score = calculateScore(metrics, issues);
    return RoastResult(score: score, issues: issues, metrics: metrics);
  }
}
