import 'package:flutter/material.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4. COMMENTS')),
      body: Center(
        child: Text('4. COMMENTS', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
