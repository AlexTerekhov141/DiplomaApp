import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Routes/routes.gr.dart';
import '../../bloc/AuthBloc/authbloc.dart';
import '../../models/Processing_mode.dart';

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
          previous.status != current.status ||
          previous.userChoice != current.userChoice ||
          previous.processingMode != current.processingMode,
      listener: (BuildContext context, AuthState state) {
        if (state.isLoading || state.status == AuthStatus.unknown) {
          return;
        }

        if (!state.userChoice) {
          context.router.replaceAll(<PageRouteInfo>[
            const AppMode(),
          ]);
          return;
        }

        if (state.processingMode == ProcessingMode.offline) {
          context.router.replaceAll(<PageRouteInfo>[
            AppRoute(),
          ]);
          return;
        }

        if (state.status == AuthStatus.authenticated) {
          context.router.replaceAll(<PageRouteInfo>[
            AppRoute(),
          ]);
          return;
        }

        if (state.status == AuthStatus.unauthenticated) {
          context.router.replaceAll(<PageRouteInfo>[
            const LoginRoute(),
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
