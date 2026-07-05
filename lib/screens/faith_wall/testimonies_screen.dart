import 'package:flutter/material.dart';

class TestimoniesScreen extends StatelessWidget {
  const TestimoniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3. TESTIMONIES')),
      body: Center(
        child: Text('3. TESTIMONIES', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
