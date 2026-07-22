import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color primary = Color(0xFF003F74);

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF02569B),
      onPrimaryContainer: Color(0xFFAACCFF),
      secondary: Color(0xFF505F76),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD0E1FB),
      onSecondaryContainer: Color(0xFF35475E),
      error: Color(0xFFBA1A1A),
      errorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFFF7F9FB),
      onSurface: Color(0xFF191C1E),
      onSurfaceVariant: Color(0xFF424751),
      outline: Color(0xFF727782),
      outlineVariant: Color(0xFFC2C6D2),
    ),
    scaffold: const Color(0xFFF7F9FB),
    card: Colors.white,
    inputFill: const Color(0xFFF2F4F6),
  );

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF111416),
    );

    return _buildTheme(
      brightness: Brightness.dark,
      scheme: scheme,
      scaffold: const Color(0xFF111416),
      card: const Color(0xFF1B1F22),
      inputFill: const Color(0xFF23282C),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color card,
    required Color inputFill,
  }) {
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      textTheme: base.textTheme
          .apply(fontFamily: 'Inter')
          .copyWith(
            headlineSmall: base.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.625),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.43),
          ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: card,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: inputFill,
        scheme: scheme,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required ColorScheme scheme,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(scheme.outlineVariant),
      enabledBorder: border(scheme.outlineVariant),
      focusedBorder: border(scheme.primary, 2),
    );
  }
}
