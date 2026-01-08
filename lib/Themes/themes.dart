import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Themes {
  ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Blue.c500,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Base.c50,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Base.c50,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Base.c50,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Base.c950, fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Base.c800, fontSize: 16),
        bodySmall: TextStyle(color: Colors.grey.shade500, fontSize: 10),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: Base.c50,
        selectedColor: Base.c50,
        disabledColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: Base.c400,
        ),
        secondaryLabelStyle: TextStyle(
          color: Blue.c500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Base.c500),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Blue.c500,
      brightness: Brightness.dark,
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Base.c950,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: Base.c50,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: Base.c950,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Base.c50, fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Base.c200, fontSize: 16),
        bodySmall: TextStyle(color: Colors.grey.shade400, fontSize: 10),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: Base.c900,
        selectedColor: Blue.c500,
        disabledColor: Colors.grey.shade800,
        labelStyle: TextStyle(color: Base.c200),
        secondaryLabelStyle: TextStyle(color: Base.c50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Blue.c500),
        ),
      ),
    );
  }
}
