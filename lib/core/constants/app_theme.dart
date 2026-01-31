import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color secondaryPink = Color(0xFFFF2975);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFF2C2C2C);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    colorScheme: const ColorScheme.dark(
      primary: primaryCyan,
      secondary: secondaryPink,
      surface: surfaceGrey,
      surfaceContainer: surfaceGrey,
      error: secondaryPink,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: surfaceWhite,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: surfaceWhite,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: surfaceWhite,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 18, // Readability focus
        color: surfaceWhite,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        color: surfaceWhite,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCyan,
        foregroundColor: Colors.black, // Dark text on Cyan
        textStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: surfaceWhite,
        side: const BorderSide(color: surfaceWhite, width: 2),
        textStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceGrey,
      elevation: 0, // Flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
