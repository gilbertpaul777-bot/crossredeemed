import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Community Guidelines', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text('Our Guidelines', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('CrossRedeemed is built on faith and love. Detailed guidelines are being drafted.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
