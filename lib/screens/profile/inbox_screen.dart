import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('6. INBOX')),
      body: Center(
        child: Text('6. INBOX', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
