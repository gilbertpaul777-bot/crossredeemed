import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5. POST DETAILS')),
      body: Center(
        child: Text('5. POST DETAILS', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
