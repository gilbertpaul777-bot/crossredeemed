import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2. USER MANAGEMENT')),
      body: Center(
        child: Text('2. USER MANAGEMENT', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
