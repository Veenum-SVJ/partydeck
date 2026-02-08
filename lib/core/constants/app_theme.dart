import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PartyDeck Theme - Cyberpunk Neon Design System
/// Based on PRD v2.0 specifications
class AppTheme {
  // ============ BRAND COLORS ============
  // Primary Colors
  static const Color primaryCyan = Color(0xFF00EAFF);      // Main accent (#00eaff)
  static const Color secondaryPink = Color(0xFFFF2975);    // Secondary accent (#FF2975)
  static const Color neonGreen = Color(0xFF0DF20D);        // Task engine green (#0df20d)
  static const Color accentYellow = Color(0xFFCCFF00);     // Badges, highlights (#CCFF00)
  
  // Background Colors
  static const Color backgroundBlack = Color(0xFF121212);  // Main background (#121212)
  static const Color backgroundDarker = Color(0xFF050505); // Deeper black for contrast
  
  // Surface Colors
  static const Color surfaceDark = Color(0xFF1A1A1A);      // Cards, surfaces (#1a1a1a)
  static const Color surfaceGrey = Color(0xFF2B2D2F);      // Elevated surfaces
  static const Color surfaceLight = Color(0xFF232930);     // Light surface variant
  
  // Text Colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9BB8BB);        // Muted text
  
  // ============ NEON GLOW SHADOWS ============
  static List<BoxShadow> get neonCyanGlow => [
    BoxShadow(
      color: primaryCyan.withValues(alpha: 0.5),
      blurRadius: 15,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primaryCyan.withValues(alpha: 0.3),
      blurRadius: 5,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get neonPinkGlow => [
    BoxShadow(
      color: secondaryPink.withValues(alpha: 0.5),
      blurRadius: 10,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: secondaryPink.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get neonGreenGlow => [
    BoxShadow(
      color: neonGreen.withValues(alpha: 0.5),
      blurRadius: 10,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: neonGreen.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardGlow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // ============ GRADIENTS ============
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryCyan.withValues(alpha: 0.1),
      backgroundBlack,
    ],
  );
  
  static LinearGradient get cardOverlayGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black.withValues(alpha: 0.9),
    ],
  );

  // ============ THEME DATA ============
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    colorScheme: const ColorScheme.dark(
      primary: primaryCyan,
      secondary: secondaryPink,
      tertiary: neonGreen,
      surface: surfaceDark,
      surfaceContainer: surfaceGrey,
      error: secondaryPink,
    ),
    textTheme: TextTheme(
      // Display - for large hero text
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
        letterSpacing: 2,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      // Headlines
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
        letterSpacing: 1.5,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: surfaceWhite,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: surfaceWhite,
      ),
      // Titles
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textMuted,
        letterSpacing: 2,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textMuted,
      ),
      // Body text
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        color: surfaceWhite,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: surfaceWhite,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        color: textMuted,
      ),
      // Labels
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
        letterSpacing: 1.5,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 1,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: textMuted,
        letterSpacing: 2,
      ),
    ),
    // Elevated Button - Primary Action (Cyan)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCyan,
        foregroundColor: backgroundBlack,
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    // Outlined Button - Secondary Action (White border)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: surfaceWhite,
        side: const BorderSide(color: surfaceWhite, width: 2),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryCyan, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.1),
      thickness: 1,
    ),
    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
        letterSpacing: 2,
      ),
    ),
  );
}
