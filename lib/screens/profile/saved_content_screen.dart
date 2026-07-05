import 'package:flutter/material.dart';

class SavedContentScreen extends StatelessWidget {
  const SavedContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3. SAVED CONTENT')),
      body: Center(
        child: Text('3. SAVED CONTENT', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
