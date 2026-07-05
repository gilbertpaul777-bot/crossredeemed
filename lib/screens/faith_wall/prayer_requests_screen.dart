import 'package:flutter/material.dart';

class PrayerRequestsScreen extends StatelessWidget {
  const PrayerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2. PRAYER REQUESTS')),
      body: Center(
        child: Text('2. PRAYER REQUESTS', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
