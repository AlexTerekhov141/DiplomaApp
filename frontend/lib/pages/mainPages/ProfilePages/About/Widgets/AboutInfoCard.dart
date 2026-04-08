import 'package:flutter/material.dart';

class AboutInfoCard extends StatelessWidget {
  const AboutInfoCard({
    super.key,
    required this.version,
    required this.lastUpdate,
    required this.info,
  });

  final String version;
  final String lastUpdate;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.update_outlined),
            title: const Text('Version'),
            subtitle: Text(version),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Last update'),
            subtitle: Text(lastUpdate),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Info'),
            subtitle: Text(info),
          ),
        ],
      ),
    );
  }
}