import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Modern Running App
  static const primary = Color(0xFF00D9FF); // Cyan/Electric Blue
  static const primaryDark = Color(0xFF0099CC);
  static const secondary = Color(0xFFFF006E); // Hot Pink for accent
  static const background = Color(0xFF040613); // Deeper black for higher contrast
  static const surface = Color(0xFF0F1429);
  static const surfaceVariant = Color(0xFF1A1F3A);
  
  // Glassmorphism tokens
  static const glassBorder = Color(0x4DFFFFFF);
  static const glassBackground = Color(0x14FFFFFF);
  
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A3BA);
  static const success = Color(0xFF00FF9D);
  static const warning = Color(0xFFFFCC00);
  static const error = Color(0xFFFF2E63);

  // Premium Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF00A2FF)],
  );

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
  );

  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
      error: error,
    ),
    textTheme: _buildTextTheme(Brightness.light),
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: const CardThemeData(
      elevation: 2,
    ),
  );

  // Dark Theme (Primary theme for running app)
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      surfaceContainerHighest: surfaceVariant,
      error: error,
      onPrimary: Colors.black,
      onSurface: textPrimary,
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0, // No shadow for bento-bespoke look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark ? textPrimary : Colors.black87;
    
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 72, // Massive scale for editorial impact
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: -3.0,
        color: baseColor,
        height: 1.0,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: -1.5,
        color: baseColor,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        color: baseColor,
        letterSpacing: 1.0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, // Smaller labels for editorial hierarchy
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: primary,
      ),
    );
  }

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.black,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    ),
  );
}
