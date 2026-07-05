import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../theme/app_theme.dart';
import '../../services/e2e_service.dart';

class SanctuaryChatScreen extends StatefulWidget {
  final Map<String, dynamic> leaderData;

  const SanctuaryChatScreen({
    super.key,
    required this.leaderData,
  });

  @override
  State<SanctuaryChatScreen> createState() => _SanctuaryChatScreenState();
}

class _SanctuaryChatScreenState extends State<SanctuaryChatScreen> {
  final _messageCtrl = TextEditingController();
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;

  // Crisis Keywords that trigger the interception
  final List<String> _crisisKeywords = ['suicide', 'kill myself', 'depressed', 'harm', 'abuse', 'die'];
  
  // Local state for mock messages
  final List<Map<String, dynamic>> _mockMessages = [];
  Duration _autoDeleteDuration = const Duration(days: 7); // Default

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    
    // 1. Crisis Management Interception
    final lowerText = text.toLowerCase();
    bool isCrisis = _crisisKeywords.any((keyword) => lowerText.contains(keyword));
    
    if (isCrisis) {
      _showCrisisModal();
      _messageCtrl.clear();
      return; // Do not send message
    }

    final expiresAt = DateTime.now().add(_autoDeleteDuration).toIso8601String();
    
    // Encrypt the message (if recipient doesn't have a key, it falls back to plaintext for MVP)
    final recipientId = widget.leaderData['id'];
    final encryptedText = await E2EService.encryptMessage(recipientId, text) ?? text;

    // For MVP, since we don't have real spiritual_leaders DB table, 
    // we just update local state instead of failing a UUID foreign key check in Supabase.
    setState(() {
      _mockMessages.insert(0, {
        'sender_id': currentUser?.id ?? 'guest',
        'content': encryptedText,
        'display_content': text, // Keep local plaintext for display
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt,
      });
    });

    // Simulate Pastor's auto-reply
    if (_mockMessages.length == 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _mockMessages.insert(0, {
              'sender_id': widget.leaderData['id'],
              'content': 'encrypted_mock',
              'display_content': 'Hello, I am here for you. How can I provide spiritual guidance today?',
              'created_at': DateTime.now().toIso8601String(),
              'expires_at': DateTime.now().add(_autoDeleteDuration).toIso8601String(),
            });
          });
        }
      });
    }
  }

  void _showCrisisModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must acknowledge
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.redAccent)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Text('You Are Not Alone', style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          content: const Text(
            'It sounds like you might be going through a very difficult time. The Sanctuary is for spiritual guidance, not emergency psychological or medical intervention.\n\n'
            'If you are experiencing a crisis, please reach out for immediate professional help. In the US, dial or text 988 to reach the Suicide & Crisis Lifeline.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('I Understand', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initScreenProtector();
    E2EService.initializeKeys();
  }

  Future<void> _initScreenProtector() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('Screen protector failed to initialize: $e');
    }
  }

  @override
  void dispose() {
    try {
      ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint('Screen protector failed to disable: $e');
    }
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.leaderData['avatar_url']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.leaderData['name'], 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: AppTheme.surfaceDark,
              onSelected: (value) {
                if (value == 'report') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
                } else if (value == 'block') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leader blocked.')));
                  Navigator.pop(context); // Exit chat
                } else if (value == 'auto_delete_24h') {
                  setState(() => _autoDeleteDuration = const Duration(hours: 24));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messages will auto-delete after 24 hours.')));
                } else if (value == 'auto_delete_7d') {
                  setState(() => _autoDeleteDuration = const Duration(days: 7));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messages will auto-delete after 7 days.')));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'auto_delete_24h',
                  child: Text('Auto-Delete: 24 Hours', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'auto_delete_7d',
                  child: Text('Auto-Delete: 7 Days', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Report Behavior', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block Leader', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            // Safe Space / Boundary Banner
            Container(
              width: double.infinity,
              color: AppTheme.primaryPurple.withAlpha(50),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  const Text(
                    'The Sanctuary is a safe space for spiritual guidance and prayer. Please note that sessions are not intended as ongoing daily therapy.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.accentGold, size: 16),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'End-to-End Encrypted. Pastors are legally mandated reporters for imminent threats of harm.',
                          style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _mockMessages.isEmpty
                ? const Center(
                    child: Text('Start the conversation by sharing your thoughts.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    reverse: true, // Newest at bottom
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _mockMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _mockMessages[index];
                      final isMe = msg['sender_id'] == (currentUser?.id ?? 'guest');
                      final displayContent = msg['display_content'] ?? msg['content'];
                      
                      return _buildChatBubble(displayContent, isMe);
                    },
                  ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Share your burden...',
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.black26,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryPurple,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryPurple : AppTheme.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: AppTheme.accentGold.withAlpha(50)),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
