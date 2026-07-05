import 'package:flutter/material.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4. COMMUNITY GUIDELINES')),
      body: Center(
        child: Text('4. COMMUNITY GUIDELINES', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
