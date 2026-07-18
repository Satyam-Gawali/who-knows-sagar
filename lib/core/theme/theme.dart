import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // Primary
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,

      // Secondary
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,

      // Tertiary
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,

      // Error
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,

      // Surface
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,

      // Outline
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,

      // Inverse
      inversePrimary: AppColors.inversePrimary,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,

      // Tint
      surfaceTint: AppColors.surfaceTint,
    ),

    scaffoldBackgroundColor: AppColors.background,

    dividerColor: AppColors.outlineVariant,

    // -----------------------------------------------------------------
    // App Bar
    // -----------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      centerTitle: true,

      elevation: 0,

      backgroundColor: AppColors.background,

      foregroundColor: AppColors.text,

      surfaceTintColor: Colors.transparent,
    ),

    // -----------------------------------------------------------------
    // Cards
    // -----------------------------------------------------------------
    cardTheme: CardThemeData(
      elevation: 0,

      color: AppColors.surfaceContainerLow,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // -----------------------------------------------------------------
    // Filled Button
    // -----------------------------------------------------------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,

        foregroundColor: AppColors.onPrimary,

        minimumSize: const Size.fromHeight(56),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),

    // -----------------------------------------------------------------
    // Outlined Button
    // -----------------------------------------------------------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,

        side: const BorderSide(color: AppColors.primary),

        minimumSize: const Size.fromHeight(56),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),

    // -----------------------------------------------------------------
    // Input Field
    // -----------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: AppColors.surfaceContainer,

      hintStyle: const TextStyle(color: AppColors.subText),

      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),

        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),

        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),

        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),

        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),

        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // -----------------------------------------------------------------
    // Divider
    // -----------------------------------------------------------------
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariant,
      thickness: 1,
    ),
  );
}
