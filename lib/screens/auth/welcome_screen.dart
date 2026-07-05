import 'package:flutter/material.dart';
import 'package:cross_redeemed/screens/auth/login_screen.dart';
import 'package:cross_redeemed/screens/auth/sign_up_screen.dart';
import 'package:cross_redeemed/screens/main_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              MediaQuery.of(context).size.aspectRatio > 1.0 
                  ? 'assets/images/welcome_16_9.png' 
                  : 'assets/images/welcome_9_16.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // Login Hitbox (Blue) - TOP
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 380.0, right: 110.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Container(
                      width: 250,
                      height: 50,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            // Sign Up Hitbox (Green) - MIDDLE
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 300.0, right: 110.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: Container(
                      width: 250,
                      height: 50,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            // Guest Hitbox (Red)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 253.0, right: 110.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
                    },
                    child: Container(
                      width: 250,
                      height: 30,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
