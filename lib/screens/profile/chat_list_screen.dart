import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7. CHAT LIST')),
      body: Center(
        child: Text('7. CHAT LIST', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
