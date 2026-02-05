import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:categorize_app/cards/ChoiceCard.dart';
import 'package:categorize_app/cards/ProfileCard.dart';
import 'package:categorize_app/cards/StatisticsCard.dart';
import 'package:categorize_app/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/AuthBloc/bloc.dart';


@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final AuthState authState = context.watch<AuthBloc>().state;
    final bool isAuth = authState.isAuthenticated;
    final User user = authState.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              ProfileCard(
                hasAccount: isAuth,
                name: isAuth ? '${user.firstName} ${user.lastName}' : null,
                mail: isAuth ? user.email : null,
                image: isAuth && user.imagePath.isNotEmpty
                    ? AssetImage(user.imagePath)
                    : const AssetImage('assets/profiles/profile.png'),
                onEdit: isAuth
                    ? () {context.router.push(EditRoute());}
                    : null,
              ),
              const SizedBox(height: 24),
              const StatisticsCard(),
              const SizedBox(height: 32),
              ChoiceCard(
                header: 'Information',
                titles: const <String>['About', 'Support'],
                icons: const <IconData>[Icons.info, Icons.help],
                colors: <Color>[Colors.grey.shade800, Colors.grey.shade800],
                onTapList: <VoidCallback>[
                      () { print('About tapped'); },
                      () { print('Support tapped'); },
                ],
              ),

              ChoiceCard(
                header: 'Preferences',
                titles: const <String>['App settings', 'Log out'],
                icons: const <IconData>[
                  Icons.settings_outlined,
                  Icons.logout
                ],
                colors: <Color>[
                  Colors.grey.shade800,
                  Colors.red,
                ],
                onTapList: <VoidCallback>[
                      () { print('App settings'); },
                      () { context.read<AuthBloc>().add(AuthLogout());},
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
