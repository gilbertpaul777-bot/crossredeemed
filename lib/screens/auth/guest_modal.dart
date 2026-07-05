import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:cross_redeemed/screens/auth/login_screen.dart';
import 'package:cross_redeemed/screens/auth/sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              // Stained glass gradient simulation
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.3),
                  AppTheme.accentGold.withValues(alpha: 0.1),
                  AppTheme.darkBlue.withValues(alpha: 0.3),
                  AppTheme.surfaceDark.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.white10, width: 1), // Subtle glass edge
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.church_outlined, size: 64, color: AppTheme.accentGold),
                const SizedBox(height: 16),
                Text(
                  'Join the Community!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create an account to like posts, leave comments, and share your own testimonies.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      shadowColor: AppTheme.accentGold.withValues(alpha: 0.5),
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close modal
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                    },
                    child: Text('Sign Up', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentGold, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close modal
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: Text('Log In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
