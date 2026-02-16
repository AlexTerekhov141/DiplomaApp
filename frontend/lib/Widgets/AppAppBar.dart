import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/themebloc/bloc.dart';
import '../bloc/themebloc/events.dart';
import '../bloc/themebloc/states.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const Icon(Icons.add),
      actions: <Widget>[_ProfileWidget(context), _switchTheme()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget _switchTheme() {
  return BlocBuilder<ThemeBloc, ThemeState>(
    builder: (BuildContext context, ThemeState state) {
      final bool isDark = state.themeMode == ThemeMode.dark;
      return IconButton(
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        onPressed: () {
          context.read<ThemeBloc>().add(ToggleThemeEvent());
        },
      );
    },
  );
}

Widget _ProfileWidget(BuildContext context) {
  return IconButton(
    onPressed: () {
      context.router.push(const ProfileRoute());
    },
    icon: const Icon(Icons.person),
  );
}
