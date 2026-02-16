import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/AuthBloc/bloc.dart';

class RouteGuard  extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final BuildContext? context = router.navigatorKey.currentContext;

    if (context == null) {
      resolver.next(false);
      return;
    }

    final AuthBloc authBloc = context.read<AuthBloc>();
    final bool isAuth = authBloc.state.isAuthenticated;

    if (isAuth) {
      resolver.next(true);
    } else {
      final bool isLoginOnTop = router.current.name == LoginRoute.name;
      if (!isLoginOnTop) {
        router.push(LoginRoute());
      }
      resolver.next(false);
    }
  }
}
