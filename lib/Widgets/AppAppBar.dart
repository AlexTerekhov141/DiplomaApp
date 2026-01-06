import 'package:flutter/material.dart';


class AppAppBar extends StatelessWidget  implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: const Icon(Icons.add),
        actions:<Widget>[
          ElevatedButton(
              onPressed: ()=><dynamic, dynamic>{},
              child: const Icon(Icons.person)
          ),
          ElevatedButton(
              onPressed: ()=><dynamic, dynamic>{},
              child: const Icon(Icons.dark_mode)
          )
        ]
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


/*Widget _switchTheme(){
  return  BlocBuilder<ThemeBloc, ThemeState>(
    builder: (BuildContext context, ThemeState state) {
      return IconButton(
        icon: Icon(
          state.isLight ? Icons.dark_mode : Icons.light_mode,
        ),
        onPressed: () {
          context.read<ThemeBloc>().add(ToggleThemeEvent());
        },
      );
    },
  );
}*/
