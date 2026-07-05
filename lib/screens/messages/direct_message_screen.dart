import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';
import 'package:cross_redeemed/widgets/interactive_verified_badge.dart';
import 'package:intl/intl.dart';

class DirectMessageScreen extends StatefulWidget {
  final String partnerId;
  final String partnerUsername;
  final BadgeType? badgeType;

  const DirectMessageScreen({
    super.key,
    required this.partnerId,
    required this.partnerUsername,
    this.badgeType,
  });

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final _messageCtrl = TextEditingController();
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;
  
  final List<Map<String, dynamic>> _mockMessages = [
    {
      'sender_id': 'mock-partner',
      'content': 'This is the start of your conversation.',
      'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    }
  ];

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || currentUser == null) return;
    
    _messageCtrl.clear();
    
    // Auto-reply logic for mock chats
    if (widget.partnerId.startsWith('mock')) {
      setState(() {
        _mockMessages.insert(0, {
          'sender_id': currentUser!.id,
          'content': text,
          'created_at': DateTime.now().toIso8601String(),
        });
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _mockMessages.insert(0, {
              'sender_id': widget.partnerId,
              'content': 'This is an automated reply from ${widget.partnerUsername}.',
              'created_at': DateTime.now().toIso8601String(),
            });
          });
        }
      });
      return;
    }
    
    try {
      await supabase.from('direct_messages').insert({
        'sender_id': currentUser!.id,
        'receiver_id': widget.partnerId, // Must be UUID
        'content': text,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surfaceDark,
                child: IchthysIcon(color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.partnerUsername, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                      if (widget.badgeType != null) ...[
                        const SizedBox(width: 4),
                        InteractiveVerifiedBadge(type: widget.badgeType!, size: 16),
                      ],
                    ],
                  ),
                  const Text('Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: currentUser == null 
                ? const Center(child: Text('Not logged in', style: TextStyle(color: Colors.white54)))
                : _mockMessages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Say hello!', style: TextStyle(color: Colors.white54)),
                      )
                    : ListView.builder(
                        reverse: true, // Newest at bottom
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: _mockMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _mockMessages[index];
                          final isMe = msg['sender_id'] == currentUser!.id;
                          return _buildChatBubble(msg['content'], isMe, DateTime.parse(msg['created_at']));
                        },
                      ),
            ),
            
            // Modern Input Area
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, DateTime timestamp) {
    final timeStr = DateFormat('h:mm a').format(timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isMe)
              // Gradient Bubble for Outgoing
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentGold, AppTheme.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
              )
            else
              // Frosted Glass Bubble for Incoming
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(timeStr, style: const TextStyle(color: Colors.white30, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, 
        right: 16, 
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(80),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 28),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppTheme.primaryPurple, Color(0xFF6A1B9A)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
