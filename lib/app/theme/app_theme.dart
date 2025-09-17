// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

// Custom theme extension for additional colors
class AppColors extends ThemeExtension<AppColors> {
  final Color? warning;
  final Color? info;
  final Color? error;
  final Color? success;

  const AppColors({
    this.warning,
    this.info,
    this.error,
    this.success,
  });

  @override
  AppColors copyWith({
    Color? warning,
    Color? info,
    Color? error,
    Color? success,
  }) {
    return AppColors(
      warning: warning ?? this.warning,
      info: info ?? this.info,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      warning: Color.lerp(warning, other.warning, t),
      info: Color.lerp(info, other.info, t),
      error: Color.lerp(error, other.error, t),
      success: Color.lerp(success, other.success, t),
    );
  }
}

class AppTheme {
  // Enhanced Color Palette
  static const Color primaryColor = Color(0xFF6366F1); // Modern indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // Background colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFFEFEFE);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: _createMaterialColor(primaryColor),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        warning: warningColor,
        info: infoColor,
        error: errorColor,
        success: successColor,
      ),
    ],

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: Color(0xFFEEF2FF),
      secondary: secondaryColor,
      secondaryContainer: Color(0xFFD1FAE5),
      tertiary: accentColor,
      tertiaryContainer: Color(0xFFFEF3C7),
      error: errorColor,
      errorContainer: Color(0xFFFEE2E2),
      background: backgroundColor,
      surface: surfaceColor,
      surfaceVariant: Color(0xFFF4F4F5),
      onPrimary: Colors.white,
      onPrimaryContainer: Color(0xFF312E81),
      onSecondary: Colors.white,
      onSecondaryContainer: Color(0xFF064E3B),
      onTertiary: Colors.white,
      onTertiaryContainer: Color(0xFF92400E),
      onBackground: Color(0xFF1F2937),
      onSurface: Color(0xFF374151),
      onSurfaceVariant: Color(0xFF52525B),
      outline: Color(0xFFD4D4D8),
      outlineVariant: Color(0xFFE4E4E7),
    ),

    // Enhanced AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: Color(0xFF1F2937),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF1F2937),
        size: 24,
      ),
    ),

    // Enhanced Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Enhanced Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4D4D8), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: Color(0xFFA1A1AA),
        fontSize: 16,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF52525B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Enhanced Card Theme
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: _createMaterialColor(primaryColor),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),

    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        warning: warningColor,
        info: infoColor,
        error: errorColor,
        success: successColor,
      ),
    ],

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: Color(0xFF312E81),
      secondary: secondaryColor,
      secondaryContainer: Color(0xFF064E3B),
      tertiary: accentColor,
      tertiaryContainer: Color(0xFF92400E),
      error: errorColor,
      errorContainer: Color(0xFF7F1D1D),
      background: Color(0xFF0F0F0F),
      surface: Color(0xFF1A1A1A),
      surfaceVariant: Color(0xFF2A2A2A),
      onPrimary: Colors.white,
      onPrimaryContainer: Color(0xFFEEF2FF),
      onSecondary: Colors.white,
      onSecondaryContainer: Color(0xFFD1FAE5),
      onTertiary: Colors.white,
      onTertiaryContainer: Color(0xFFFEF3C7),
      onBackground: Color(0xFFF9FAFB),
      onSurface: Color(0xFFE5E7EB),
      onSurfaceVariant: Color(0xFF9CA3AF),
      outline: Color(0xFF4B5563),
      outlineVariant: Color(0xFF374151),
    ),
  );

  // Helper method to create MaterialColor
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}