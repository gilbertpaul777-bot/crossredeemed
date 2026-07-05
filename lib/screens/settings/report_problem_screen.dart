import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportProblemScreen extends StatelessWidget {
  const ReportProblemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Report a Problem', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.report_problem_outlined, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text('Found a bug?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('The reporting system is currently under construction. Please try again later.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
