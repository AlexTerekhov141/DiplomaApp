import 'package:flutter/material.dart';

import '../../../../../models/PhotoRoastModels/RoastIssue.dart';
import 'RoastSeverityChip.dart';


class RoastIssueTile extends StatelessWidget {
  const RoastIssueTile({
    super.key,
    required this.issue,
  });

  final RoastIssue issue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(issue.title),
        subtitle: Text(
          issue.whyItHurts,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: RoastSeverityChip(severity: issue.severity),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              issue.howToFix,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}