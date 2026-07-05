import 'package:flutter/material.dart';

class ReportsQueueScreen extends StatelessWidget {
  const ReportsQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4. REPORTS QUEUE')),
      body: Center(
        child: Text('4. REPORTS QUEUE', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
