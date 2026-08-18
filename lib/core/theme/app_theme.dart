import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF10B981); // Modern Emerald
  static const Color accent = Color(0xFF82CBAE); // Soft Sage
  static const Color background = Color(0xFFF7F9F9); // Whisper Gray
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color text = Color(0xFF1E293B); // Dark Slate

  // Reusable soft shadow to prevent harsh black drop shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: text.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

const _smoothTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  },
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  pageTransitionsTheme: _smoothTransitions,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    background: AppColors.background,
    surfaceContainerHighest: AppColors.text.withOpacity(0.05),
    secondaryContainer: AppColors.primary,
    onSecondaryContainer: const Color(0xFFFFFFFF),
    outline: const Color(0xFF64748B),
    outlineVariant: AppColors.text.withOpacity(0.15),
    onSurfaceVariant: AppColors.text.withOpacity(0.6),
    primaryContainer: const Color(0xFFE6F8F3),
  ),
  appBarTheme: const AppBarTheme(centerTitle: true),
  // Single source of truth for card surfaces. surfaceTintColor: transparent
  // keeps the color exact at any elevation (M3 would otherwise tint it).
  cardTheme: const CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 3,
    margin: EdgeInsets.zero,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
    titleLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: TextStyle(color: AppColors.text.withOpacity(0.4)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
);

// Modern Clinic Dark Theme Palette
class AppDarkColors {
  static const Color primary = Color(0xFF82CBAE); // Soft Sage
  static const Color accent = Color(0xFF82CBAE); // Soft Sage
  static const Color background = Color(0xFF121A19); // Dark Pine
  static const Color surface = Color(0xFF1E2A28); // Elevated Pine
  static const Color text = Color(0xFFFFFFFF); // Pure White as requested

  static const Color textSecondary = Color(0xFF8E9E9B); // Muted Grey-Green
  static const Color inputFill = Color(0xFF1A2523); // Input Field Background

  static const Color surfaceVariant = Color(
    0xFF2A3A37,
  ); // Seg Tab Bar Container / Add Profile Container
  static const Color onPrimaryActiveText = Color(0xFF121A19);
  static const Color inactiveTabText = Color(0xFFA5BDB9);
  static const Color navInactive = Color(0xFFB0C4C1);
  static const Color emptyIllustration = Color(0xFF4A625D);
  static const Color activeTab = Color(0xFF4DB6AC); // Bright Vibrant Green
}

final ThemeData darkAppTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppDarkColors.background,
  pageTransitionsTheme: _smoothTransitions,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppDarkColors.primary,
    primary: AppDarkColors.primary,
    secondary: AppDarkColors.accent,
    surface: AppDarkColors.surface,
    background: AppDarkColors.background,
    brightness: Brightness.dark,
    onSurface: AppDarkColors.text,
    onSurfaceVariant: AppDarkColors.navInactive,
    surfaceContainerHighest: AppDarkColors.surfaceVariant,
    secondaryContainer: AppDarkColors.activeTab,
    onSecondaryContainer: AppDarkColors.onPrimaryActiveText,
    outline: AppDarkColors.inactiveTabText,
    outlineVariant: AppDarkColors.emptyIllustration,
    primaryContainer: AppDarkColors.surfaceVariant,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppDarkColors.background,
    foregroundColor: AppDarkColors.text,
    elevation: 0,
    centerTitle: true,
  ),
  // Elevated pine surface — distinct from the darker scaffold background.
  cardTheme: const CardThemeData(
    color: AppDarkColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 3,
    margin: EdgeInsets.zero,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppDarkColors.text),
    bodyMedium: TextStyle(color: AppDarkColors.text),
    titleLarge: TextStyle(
      color: AppDarkColors.text,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppDarkColors.inputFill,
    hintStyle: const TextStyle(color: AppDarkColors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
);
