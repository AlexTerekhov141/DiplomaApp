import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ..._withDividers(children),
          ],
        ),
      ),
    );
  }
}

List<Widget> _withDividers(List<Widget> items) {
  if (items.isEmpty) {
    return const <Widget>[];
  }

  final List<Widget> output = <Widget>[];
  for (int i = 0; i < items.length; i++) {
    output.add(items[i]);
    if (i != items.length - 1) {
      output.add(const Divider(height: 1));
    }
  }
  return output;
}