import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:categorize_app/cards/ChoiceCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePreferences extends StatelessWidget {
  const ProfilePreferences({super.key});

  @override
  Widget build(BuildContext context) {
    return ChoiceCard(

      header: 'Preferences',
      titles: const <String>['App settings', 'Log out'],
      icons: const <IconData>[
        Icons.settings_outlined,
        Icons.logout,
      ],
      colors: <Color>[Colors.grey.shade800, Colors.red],
      onTapList: <VoidCallback>[
            () {
          context.router.push(const SettingsRoute());
        },
            () {
          context.read<AuthBloc>().add(AuthLogout());
        },
      ],
    );
  }
}