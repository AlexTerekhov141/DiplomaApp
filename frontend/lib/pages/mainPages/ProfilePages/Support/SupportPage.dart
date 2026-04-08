import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import '../../../../constants/AppConstantsModels/SupportInfo.dart';
import 'Widgets/SupportContacts.dart';
import 'Widgets/SupportInfoCard.dart';



@RoutePage()
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: ResponsiveFrame(
        maxWidth: 760,
        child: ListView(
          children: const <Widget>[
            SupportContactsCard(
              email: SupportInfo.email,
              telegram: SupportInfo.telegram,
            ),
            SizedBox(height: 12),
            SupportInfoCard(
              info: SupportInfo.info,
            ),
          ],
        ),
      ),
    );
  }
}