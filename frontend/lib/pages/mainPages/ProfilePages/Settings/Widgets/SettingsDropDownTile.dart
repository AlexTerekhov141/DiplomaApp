import 'package:flutter/material.dart';

import 'SettingsTileIcon.dart';

class SettingsDropdownTile extends StatelessWidget {
  const SettingsDropdownTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SettingsTileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        onChanged: (String? value) {
          if (value != null) {
            onChanged(value);
          }
        },
        items: values
            .map(
              (String item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
        )
            .toList(),
      ),
    );
  }
}