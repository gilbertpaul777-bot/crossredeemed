import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3. HELP CENTER')),
      body: Center(
        child: Text('3. HELP CENTER', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
