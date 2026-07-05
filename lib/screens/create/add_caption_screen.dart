import 'package:flutter/material.dart';

class AddCaptionScreen extends StatelessWidget {
  const AddCaptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5. ADD CAPTION')),
      body: Center(
        child: Text('5. ADD CAPTION', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
