import 'package:flutter/material.dart';

import 'SettingsTileIcon.dart';


class SettingsInfoTile extends StatelessWidget {
  const SettingsInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      leading: SettingsTileIcon(icon: icon),
      title: Text(
        title,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
