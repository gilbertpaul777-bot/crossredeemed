import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _likes = true;
  bool _comments = true;
  bool _newFollowers = true;
  bool _directMessages = true;
  bool _mentions = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('In-app Notifications', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          ),
          _buildSwitch('Likes', _likes, (val) => setState(() => _likes = val)),
          _buildSwitch('Comments', _comments, (val) => setState(() => _comments = val)),
          _buildSwitch('New Followers', _newFollowers, (val) => setState(() => _newFollowers = val)),
          _buildSwitch('Mentions', _mentions, (val) => setState(() => _mentions = val)),
          _buildSwitch('Direct Messages', _directMessages, (val) => setState(() => _directMessages = val)),
        ],
      ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.accentGold,
      activeTrackColor: AppTheme.primaryPurple,
    );
  }
}
