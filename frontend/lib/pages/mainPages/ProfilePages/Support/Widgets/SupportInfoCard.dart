import 'package:flutter/material.dart';

class SupportInfoCard extends StatelessWidget {
  const SupportInfoCard({
    super.key,
    required this.info,
  });

  final String info;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Info'),
        subtitle: Text(info),
      ),
    );
  }
}