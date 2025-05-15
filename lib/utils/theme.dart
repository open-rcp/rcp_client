import 'package:flutter/material.dart';

/// Color scheme and theme for the application
class AppTheme {
  /// Primary color
  static const Color primaryColor = Color(0xFF2D5DA9);

  /// Secondary color
  static const Color secondaryColor = Color(0xFF50C878);

  /// Background color for dark theme
  static const Color darkBackgroundColor = Color(0xFF1E1E1E);

  /// Surface color for dark theme
  static const Color darkSurfaceColor = Color(0xFF2A2A2A);

  /// Error color
  static const Color errorColor = Color(0xFFB71C1C);

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  /// Dark theme
  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
        surface: darkBackgroundColor, // Updated from background to surface
        surfaceContainerLowest: darkSurfaceColor,
      ),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: darkSurfaceColor,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
