import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF4D6D);
  static const Color secondary = Color(0xFFFF85A1);
  static const Color accent = Color(0xFFFFB3C1);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  
  static const LinearGradient loveGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFF7B2CBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white24, Colors.white10],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppThemes {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
  );
}
