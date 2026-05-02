import 'package:flutter/material.dart';

class SystexColors {
  static const Color brandRed = Color(0xFFFF2A2A);
  static const Color background = Color(0xFF121212);
  static const Color backgroundAlt = Color(0xFF0F0F10);
  static const Color surface = Color(0xFF15171B);
  static const Color glass = Color(0xCC1B1E24);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFFB3B8C3);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
}

class AppTheme {
  static ThemeData get systexDarkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: SystexColors.brandRed,
          brightness: Brightness.dark,
        ).copyWith(
          primary: SystexColors.brandRed,
          secondary: SystexColors.brandRed,
          surface: SystexColors.surface,
          error: const Color(0xFFFF5252),
          onPrimary: Colors.white,
          onSurface: SystexColors.textPrimary,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Nunito',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SystexColors.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: SystexColors.textPrimary),
        headlineMedium: TextStyle(color: SystexColors.textPrimary),
        headlineSmall: TextStyle(color: SystexColors.textPrimary),
        titleLarge: TextStyle(color: SystexColors.textPrimary),
        titleMedium: TextStyle(color: SystexColors.textPrimary),
        titleSmall: TextStyle(color: SystexColors.textSecondary),
        bodyLarge: TextStyle(color: SystexColors.textPrimary),
        bodyMedium: TextStyle(color: SystexColors.textSecondary),
        bodySmall: TextStyle(color: SystexColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SystexColors.backgroundAlt.withValues(alpha: 0.92),
        foregroundColor: SystexColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: SystexColors.textPrimary,
          fontFamily: 'Nunito',
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: SystexColors.surface.withValues(alpha: 0.98),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),
      cardTheme: CardThemeData(
        color: SystexColors.glass,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.30),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SystexColors.glassBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SystexColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: SystexColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: SystexColors.textSecondary,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SystexColors.surface.withValues(alpha: 0.96),
        contentTextStyle: const TextStyle(color: SystexColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF17191D),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: SystexColors.textSecondary),
        labelStyle: const TextStyle(color: SystexColors.textSecondary),
        prefixIconColor: SystexColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: SystexColors.brandRed,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SystexColors.brandRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: SystexColors.brandRed.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SystexColors.textPrimary,
          side: BorderSide(
            color: SystexColors.brandRed.withValues(alpha: 0.85),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.10),
    );

    return base;
  }

  static ThemeData get darkTheme => systexDarkTheme;
  static ThemeData get lightTheme => systexDarkTheme;
}
