import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Themes/themes.dart';
import 'events.dart';
import 'states.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {

  ThemeBloc() : super(ThemeState(Themes().lightTheme, true)) {
    on<ToggleThemeEvent>((ToggleThemeEvent event, Emitter<ThemeState> emit) {
      isLight = !isLight;
      emit(ThemeState(isLight ? themes.lightTheme : themes.darkTheme, isLight));
    });

  }
  final Themes themes = Themes();
  bool isLight = true;
}