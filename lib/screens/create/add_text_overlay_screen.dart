import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AddTextOverlayScreen extends StatefulWidget {
  const AddTextOverlayScreen({super.key});

  @override
  State<AddTextOverlayScreen> createState() => _AddTextOverlayScreenState();
}

class _AddTextOverlayScreenState extends State<AddTextOverlayScreen> {
  final TextEditingController _textCtrl = TextEditingController();

  void _done() {
    final text = _textCtrl.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Text'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text('Done', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: TextField(
            controller: _textCtrl,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Type your text here...',
              hintStyle: TextStyle(color: Colors.white30),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
