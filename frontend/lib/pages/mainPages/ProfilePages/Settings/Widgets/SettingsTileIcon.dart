import 'package:flutter/material.dart';

class SettingsTileIcon extends StatelessWidget {
  const SettingsTileIcon({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: theme.colorScheme.primary,
      ),
    );
  }
}