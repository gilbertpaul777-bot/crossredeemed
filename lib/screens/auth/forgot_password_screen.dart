import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4. FORGOT PASSWORD')),
      body: Center(
        child: Text('4. FORGOT PASSWORD', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
