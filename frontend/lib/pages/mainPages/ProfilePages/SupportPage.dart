import 'package:auto_route/annotations.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ResponsiveFrame(
        maxWidth: 760,
        child: ListView(
          children: const <Widget>[
            Card(
              elevation: 0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.mail_outline),
                    title: Text('Email support'),
                    subtitle: Text('support@categorize.app'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.telegram),
                    title: Text('Telegram (questions)'),
                    subtitle: Text('@categorize_support'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Info'),
                subtitle: Text(
                  'Support email, messenger contact, FAQ link, '
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
