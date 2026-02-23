import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A5C53); // Deep Teal
  static const Color accent = Color(0xFF82CBAE);  // Soft Sage
  static const Color background = Color(0xFFF7F9F9); // Whisper Gray
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color text = Color(0xFF2C3E50); // Dark Slate

  // Reusable soft shadow to prevent harsh black drop shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: text.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    background: AppColors.background,
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
