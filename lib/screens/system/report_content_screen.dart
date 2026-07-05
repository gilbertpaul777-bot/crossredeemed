import 'package:flutter/material.dart';

class ReportContentScreen extends StatelessWidget {
  const ReportContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2. REPORT CONTENT')),
      body: Center(
        child: Text('2. REPORT CONTENT', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
