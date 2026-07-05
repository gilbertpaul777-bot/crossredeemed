import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7. PRIVACY POLICY')),
      body: Center(
        child: Text('7. PRIVACY POLICY', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
