import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/cards/ChoiceCard.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChoiceCard(
      header: 'Information',
      titles: const <String>['About', 'Support'],
      icons: const <IconData>[Icons.info, Icons.help],
      colors: <Color>[Colors.grey.shade800, Colors.grey.shade800],
      onTapList: <VoidCallback>[
            () {
          context.router.push(const AboutRoute());
        },
            () {
          context.router.push(const SupportRoute());
        },
      ],
    );
  }
}