import 'package:flutter/material.dart';

class SupportContactsCard extends StatelessWidget {
  const SupportContactsCard({
    super.key,
    required this.email,
    required this.telegram,
  });

  final String email;
  final String telegram;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Email support'),
            subtitle: Text(email),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.telegram),
            title: const Text('Telegram (questions)'),
            subtitle: Text(telegram),
          ),
        ],
      ),
    );
  }
}