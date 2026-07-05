import 'package:flutter/material.dart';

class FollowingFeedScreen extends StatelessWidget {
  const FollowingFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2. FOLLOWING FEED')),
      body: Center(
        child: Text('2. FOLLOWING FEED', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
