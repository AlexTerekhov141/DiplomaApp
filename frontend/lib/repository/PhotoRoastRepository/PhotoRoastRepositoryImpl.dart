import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as im;

import '../../models/PhotoRoastModels/RoastModels.dart';
import 'PhotoRoastRepository.dart';


class PhotoRoastRepositoryImpl implements PhotoRoastRepository {
  @override
  Future<RoastMetrics> analyzeMetrics(Uint8List bytes) async {
    final im.Image? image = im.decodeImage(bytes);
    if (image == null) throw Exception('Invalid image bytes');

    final int w = image.width, h = image.height;
    final int n = w * h;

    final List<double> lum = List<double>.filled(n, 0, growable: false);
    int hi = 0, sh = 0, i = 0;
    double sum = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final im.Pixel p = image.getPixel(x, y);
        final double l = (0.2126 * p.r + 0.7152 * p.g + 0.0722 * p.b) / 255.0;
        lum[i++] = l;
        sum += l;
        if (l > 0.97) hi++;
        if (l < 0.03) sh++;
      }
    }

    final double mean = sum / n;
    double varSum = 0;
    for (final double l in lum) {
      final double d = l - mean;
      varSum += d * d;
    }
    final double contrast = math.sqrt(varSum / n);

    double edge = 0;
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final int idx = y * w + x;
        final double dx = (lum[idx + 1] - lum[idx - 1]).abs();
        final double dy = (lum[idx + w] - lum[idx - w]).abs();
        edge += (dx + dy) * 0.5;
      }
    }
    final double sharpness = ((w - 2) * (h - 2)) > 0 ? edge / ((w - 2) * (h - 2)) : 0.0;


    return RoastMetrics(
      brightness: mean,
      contrast: contrast,
      sharpness: sharpness,
      clippingHighlights: hi / n,
      clippingShadows: sh / n,
    );
  }

  @override
  List<RoastIssue> buildIssues(RoastMetrics m) {
    final List<RoastIssue> issues = <RoastIssue>[];

    if (m.brightness < 0.30) {
      issues.add(const RoastIssue(
        title: 'Too dark',
        whyItHurts: 'Important details are hidden in shadows.',
        howToFix: 'Add light or raise exposure.',
        severity: RoastSeverity.high,
      ));
    }
    if (m.contrast < 0.14) {
      issues.add(const RoastIssue(
        title: 'Flat contrast',
        whyItHurts: 'Image lacks depth.',
        howToFix: 'Use side lighting or increase local contrast.',
        severity: RoastSeverity.medium,
      ));
    }
    if (m.sharpness < 0.06) {
      issues.add(const RoastIssue(
        title: 'Soft focus',
        whyItHurts: 'Edges are not crisp.',
        howToFix: 'Tap-to-focus and stabilize your hands.',
        severity: RoastSeverity.high,
      ));
    }

    if (issues.isEmpty) {
      issues.add(const RoastIssue(
        title: 'Clean shot',
        whyItHurts: 'No major technical issues detected.',
        howToFix: 'Experiment with composition for more impact.',
        severity: RoastSeverity.low,
      ));
    }

    return issues;
  }

  @override
  int calculateScore(RoastMetrics m, List<RoastIssue> issues) {
    double s = 100;
    s -= (m.brightness - 0.5).abs() * 55;
    s -= (0.22 - m.contrast).clamp(0.0, 0.22) * 140;
    s -= (0.12 - m.sharpness).clamp(0.0, 0.12) * 180;
    s -= m.clippingHighlights * 120;
    s -= m.clippingShadows * 85;
    s -= issues.length * 2.5;
    return s.clamp(0, 100).round();
  }

  @override
  Future<RoastResult> run(Uint8List bytes) async {
    final RoastMetrics metrics = await analyzeMetrics(bytes);
    final List<RoastIssue> issues = buildIssues(metrics);
    final int score = calculateScore(metrics, issues);
    return RoastResult(score: score, issues: issues, metrics: metrics);
  }
}
