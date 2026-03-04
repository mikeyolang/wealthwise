import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryNavy = Color(0xFF0A192F);
  static const Color secondaryNavy = Color(0xFF112240);
  static const Color accentEmerald = Color(0xFF00C853);
  static const Color accentCoral = Color(0xFFE53935);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color textPrimary = Color(0xFFCCD6F6);
  static const Color textSecondary = Color(0xFF8892B0);
  static const Color cardBackground = Color(0xFF1D2D50);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accentEmerald,
    scaffoldBackgroundColor: primaryNavy,
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    colorScheme: ColorScheme.dark(
      primary: accentEmerald,
      secondary: accentGold,
      error: accentCoral,
      surface: secondaryNavy,
      onSurface: textPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: secondaryNavy,
      selectedItemColor: accentEmerald,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: accentEmerald,
    scaffoldBackgroundColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.grey[50],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    colorScheme: ColorScheme.light(
      primary: accentEmerald,
      secondary: accentGold,
      error: accentCoral,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: accentEmerald,
      unselectedItemColor: Colors.black38,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
