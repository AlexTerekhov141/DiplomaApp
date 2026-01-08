import 'package:auto_route/annotations.dart';
import 'package:categorize_app/cards/ChoiceCard.dart';
import 'package:categorize_app/cards/ProfileCard.dart';
import 'package:categorize_app/cards/StatisticsCard.dart';
import 'package:categorize_app/models/User.dart';
import 'package:flutter/material.dart';

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
    const User user = User(imagePath: 'assets/profiles/profile.png');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              ProfileCard(
                name: 'Alexander Terekhov',
                mail: 'terehovav52s@gmail.com',
                image: AssetImage(user.imagePath),
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
                      () { print('Logout tapped'); },
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
