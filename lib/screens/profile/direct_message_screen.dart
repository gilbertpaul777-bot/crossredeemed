import 'package:flutter/material.dart';

class DirectMessageScreen extends StatelessWidget {
  const DirectMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('8. DIRECT MESSAGE')),
      body: Center(
        child: Text('8. DIRECT MESSAGE', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
