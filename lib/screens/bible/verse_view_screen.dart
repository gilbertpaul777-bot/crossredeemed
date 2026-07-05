import 'package:flutter/material.dart';

class VerseViewScreen extends StatelessWidget {
  const VerseViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4. VERSE VIEW')),
      body: Center(
        child: Text('4. VERSE VIEW', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
