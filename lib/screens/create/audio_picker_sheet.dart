import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AudioPickerSheet extends StatelessWidget {
  final Function(String, String) onSelectSound;

  const AudioPickerSheet({super.key, required this.onSelectSound});

  static final List<Map<String, String>> _mockSounds = [
    {'title': 'Amazing Grace (Lofi)', 'artist': 'CrossRedeemed Original'},
    {'title': 'Oceans (Instrumental)', 'artist': 'Worship Beats'},
    {'title': 'Holy Spirit (Acoustic)', 'artist': 'Faith Strings'},
    {'title': 'Way Maker (Synth)', 'artist': 'Electronic Praise'},
    {'title': 'It Is Well (Piano)', 'artist': 'Calm Keys'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassBoxDecoration.copyWith(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add Sound',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white54),
                  hintText: 'Search sounds...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sound List
          Expanded(
            child: ListView.builder(
              itemCount: _mockSounds.length,
              itemBuilder: (context, index) {
                final sound = _mockSounds[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.music_note, color: AppTheme.accentGold),
                  ),
                  title: Text(sound['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(sound['artist']!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                    onPressed: () {
                      // Mock play action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Previewing ${sound['title']}...')),
                      );
                    },
                  ),
                  onTap: () {
                    onSelectSound(sound['title']!, sound['artist']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
