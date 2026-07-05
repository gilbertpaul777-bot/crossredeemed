import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1. ADMIN DASHBOARD')),
      body: Center(
        child: Text('1. ADMIN DASHBOARD', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
