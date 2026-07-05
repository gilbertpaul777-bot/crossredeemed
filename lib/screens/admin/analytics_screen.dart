import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5. ANALYTICS')),
      body: Center(
        child: Text('5. ANALYTICS', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
