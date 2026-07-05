import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text('How can we help?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Our support team is currently building out the Help Center FAQ. Please check back later.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
