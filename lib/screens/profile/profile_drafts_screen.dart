import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileDraftsScreen extends StatelessWidget {
  const ProfileDraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Drafts', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('DRAFTS', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    );
  }
}
