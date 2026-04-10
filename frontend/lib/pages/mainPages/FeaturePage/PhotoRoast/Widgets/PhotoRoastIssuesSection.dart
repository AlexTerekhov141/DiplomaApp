import 'package:flutter/material.dart';

import '../../../../../models/PhotoRoastModels/RoastIssue.dart';
import 'RoastIssueTile.dart';


class PhotoRoastIssuesSection extends StatelessWidget {
  const PhotoRoastIssuesSection({
    super.key,
    required this.showIssues,
    required this.issues,
    required this.onToggle,
  });

  final bool showIssues;
  final List<RoastIssue> issues;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onToggle,
            icon: Icon(
              showIssues ? Icons.expand_more : Icons.expand_less,
            ),
            label: Text(
              showIssues ? 'Hide problems' : 'Show problems',
            ),
          ),
        ),
        if (showIssues)
          SizedBox(
            height: 260,
            child: ListView.separated(
              itemCount: issues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                return RoastIssueTile(issue: issues[index]);
              },
            ),
          ),
      ],
    );
  }
}