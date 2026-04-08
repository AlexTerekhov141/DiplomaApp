import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:categorize_app/cards/ProfileCard.dart';
import 'package:categorize_app/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Widgets/ResponsiveFrame.dart';
import '../../../../bloc/AuthBloc/bloc.dart';
import '../../../../constants/Utils/AvatarImageResolver.dart';
import 'Widgets/ProfileInfo.dart';
import 'Widgets/ProfilePreferences.dart';
import 'Widgets/ProfileStatistics.dart';


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

  void _openEditProfile(BuildContext context) {
    context.router.push(EditRoute());
  }

  void _handleUnauthenticated(BuildContext context) {
    context.router.replaceAll(<PageRouteInfo<dynamic>>[
      const LoginRoute(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final AuthState authState = context.watch<AuthBloc>().state;
    final bool isAuth = authState.isAuthenticated;
    final User user = authState.user;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
      previous.isAuthenticated && !current.isAuthenticated,
      listener: (BuildContext context, AuthState state) {
        _handleUnauthenticated(context);
      },
      child: Scaffold(
        body: ResponsiveFrame(
          maxWidth: 860,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ProfileCard(
                  hasAccount: isAuth,
                  name: isAuth ? '${user.firstName} ${user.lastName}' : null,
                  mail: isAuth ? user.email : null,
                  image: resolveAvatarImage(user.imagePath),
                  onEdit: isAuth
                      ? () {
                    _openEditProfile(context);
                  }
                      : null,
                ),
                const SizedBox(height: 24),
                const ProfileStatistics(),
                const SizedBox(height: 32),
                const ProfileInfo(),
                const SizedBox(height: 16),
                const ProfilePreferences(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}