import 'package:flutter/material.dart';

import '../constants/colors.dart';

class Themes {
  static const double _radius = 18;

  ThemeData get lightTheme => _theme(Brightness.light);

  ThemeData get darkTheme => _theme(Brightness.dark);

  ThemeData _theme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Blue.c500,
      brightness: brightness,
    ).copyWith(
      primary: Blue.c500,
      onPrimary: Base.c50,
      secondary: Green.c500,
      onSecondary: Base.c50,
      error: Red.c500,
      surface: isDark ? Base.c950 : Base.c50,
      onSurface: isDark ? Base.c50 : Base.c950,
      surfaceContainerLowest: isDark ? Base.c950 : Base.c50,
      surfaceContainerLow: isDark ? Base.c900 : Base.c100,
      surfaceContainer: isDark ? Base.c900 : Base.c100,
      surfaceContainerHigh: isDark ? Base.c800 : Base.c200,
      surfaceContainerHighest: isDark ? Base.c800 : Base.c100,
      outline: isDark ? Base.c600 : Base.c300,
      outlineVariant: isDark ? Base.c700 : Base.c200,
    );

    final TextTheme textTheme = _textTheme(isDark);
    final BorderRadius borderRadius = BorderRadius.circular(_radius);
    final BorderSide inputBorderSide = BorderSide(
      color: isDark ? Base.c700 : Base.c200,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: isDark ? Base.c900 : Base.c50,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? Base.c900 : Base.c50,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Base.c900 : Base.c100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? Base.c300 : Base.c600,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? Base.c500 : Base.c500,
        ),
        prefixIconColor: isDark ? Base.c300 : Base.c600,
        suffixIconColor: isDark ? Base.c300 : Base.c600,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: inputBorderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: inputBorderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Blue.c500,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Red.c500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: Red.c500,
            width: 1.6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          backgroundColor: Blue.c500,
          foregroundColor: Base.c50,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          backgroundColor: Blue.c500,
          foregroundColor: Base.c50,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          foregroundColor: Blue.c500,
          side: const BorderSide(color: Blue.c500),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Blue.c500,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Blue.c500,
        foregroundColor: Base.c50,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: isDark ? Base.c900 : Base.c100,
        selectedColor: Blue.c100,
        disabledColor: isDark ? Base.c800 : Base.c200,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: Blue.c500,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: isDark ? Base.c700 : Base.c200,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? Base.c200 : Base.c700,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Blue.c500,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Base.c800 : Base.c950,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Base.c50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Base.c800 : Base.c200,
        thickness: 1,
        space: 1,
      ),
    );
  }

  TextTheme _textTheme(bool isDark) {
    final Color primaryText = isDark ? Base.c50 : Base.c950;
    final Color secondaryText = isDark ? Base.c300 : Base.c700;
    final Color mutedText = isDark ? Base.c400 : Base.c500;

    return TextTheme(
      headlineLarge: TextStyle(
        color: primaryText,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        color: primaryText,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
      ),
      headlineSmall: TextStyle(
        color: primaryText,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        color: primaryText,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
      titleSmall: TextStyle(
        color: primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: secondaryText,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: secondaryText,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: mutedText,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        color: primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      labelMedium: TextStyle(
        color: secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: mutedText,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
