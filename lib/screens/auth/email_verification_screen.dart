import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5. EMAIL VERIFICATION')),
      body: Center(
        child: Text('5. EMAIL VERIFICATION', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
