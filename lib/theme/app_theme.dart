import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors based on the "Divine" aesthetic
  static const Color primaryPurple = Color(0xFF4A148C); // Royal Purple
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentGold = Color(0xFFFFC107); // Divine Gold
  static const Color backgroundDark = Color(0xFF0B0B13);
  static const Color surfaceDark = Color(0xFF1A1A24);

  // The Signature Gradient Background (Dawn-inspired)
  static const LinearGradient nebulaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryPurple,
      backgroundDark,
      Color(0xFF311B92), // deep dawn purple
      backgroundDark,
    ],
    stops: [0.0, 0.3, 0.8, 1.0],
  );

  static final BoxDecoration glassBoxDecoration = BoxDecoration(
    color: surfaceDark.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 10,
        spreadRadius: 1,
      )
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: Colors.transparent,
      
      // Global Text Styling (Light Text)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
      ),
      
      // App Bar Styling
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: accentGold),
        titleTextStyle: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentGold,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          shadowColor: accentGold.withValues(alpha: 0.5), // Glowing drop-shadow
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
      ),
    );
  }
}
