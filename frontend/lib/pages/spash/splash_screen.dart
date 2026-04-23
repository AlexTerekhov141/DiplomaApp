import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Routes/routes.gr.dart';
import '../../bloc/AuthBloc/authbloc.dart';


@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
      previous.status != current.status,
      listener: (BuildContext context, AuthState state) {
        if (state.status == AuthStatus.authenticated && state.userChoice) {
          context.router.replaceAll(<PageRouteInfo>[
            const AppRoute(),
          ]);
        }

        if (state.status == AuthStatus.unauthenticated && state.userChoice) {
          context.router.replaceAll(<PageRouteInfo>[
            const LoginRoute(),
          ]);
        }

        if (!state.userChoice){
          context.router.replaceAll(<PageRouteInfo>[
            const AppMode(),
          ]);
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}