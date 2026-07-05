import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.privacy_tip_outlined, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Your privacy matters. The full policy is being reviewed by legal.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
