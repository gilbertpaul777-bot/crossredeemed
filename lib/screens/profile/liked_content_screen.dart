import 'package:flutter/material.dart';

class LikedContentScreen extends StatelessWidget {
  const LikedContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4. LIKED CONTENT')),
      body: Center(
        child: Text('4. LIKED CONTENT', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
