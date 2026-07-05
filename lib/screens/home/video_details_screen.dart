import 'package:flutter/material.dart';

class VideoDetailsScreen extends StatelessWidget {
  const VideoDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3. VIDEO DETAILS')),
      body: Center(
        child: Text('3. VIDEO DETAILS', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
