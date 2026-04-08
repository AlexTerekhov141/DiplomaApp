import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../models/Features/Feature.dart';

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.feature,
  });

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.router.push(feature.route);
      },
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.secondaryContainer,
              isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerLow,
            ],
          ),
          border: Border.all(
            color: isDark
                ? colorScheme.outline
                : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              feature.icon,
              size: 40,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              feature.name,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}