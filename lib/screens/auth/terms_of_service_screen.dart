import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('6. TERMS OF SERVICE')),
      body: Center(
        child: Text('6. TERMS OF SERVICE', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
