import 'package:flutter/material.dart';

class ContentModerationScreen extends StatelessWidget {
  const ContentModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3. CONTENT MODERATION')),
      body: Center(
        child: Text('3. CONTENT MODERATION', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
