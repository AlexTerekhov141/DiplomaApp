import 'package:categorize_app/pages/mainPages/FeaturePage/Functions/Functions.dart';
import 'package:flutter/material.dart';



class PhotoRoastScoreCard extends StatelessWidget {
  const PhotoRoastScoreCard({
    super.key,
    required this.score,
  });

  final int? score;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          score != null ? 'Score $score/100' : 'Score ?/100',
          style: TextStyle(
            color: scoreColor(context, score),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}