import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'direct_message_screen.dart';
import 'sanctuary_tab.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';
import 'package:cross_redeemed/widgets/interactive_verified_badge.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final supabase = Supabase.instance.client;
  final currentUser = Supabase.instance.client.auth.currentUser;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _mockChats = [
    {
      'id': 'mock-community-id',
      'username': 'Community Board',
      'last_message': 'Welcome to the Faith Wall community!',
      'time': 'Just now',
      'unread': 2,
      'is_online': true,
      'badge': BadgeType.church,
    },
    {
      'id': 'mock-pastor-id',
      'username': 'Pastor John',
      'last_message': 'God bless you today.',
      'time': '2h ago',
      'unread': 0,
      'is_online': false,
      'badge': BadgeType.user,
    },
    {
      'id': 'mock-worship-team',
      'username': 'Worship Team',
      'last_message': 'Are we still on for practice at 6?',
      'time': 'Yesterday',
      'unread': 0,
      'is_online': true,
      'badge': null,
    }
  ];

  List<Map<String, dynamic>> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = _mockChats;
    _searchCtrl.addListener(() {
      setState(() {
        final query = _searchCtrl.text.toLowerCase();
        _filteredChats = _mockChats.where((chat) => chat['username'].toLowerCase().contains(query)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.nebulaGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Inbox', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: const TabBar(
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 3,
              labelColor: AppTheme.accentGold,
              unselectedLabelColor: Colors.white54,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: 'Messages'),
                Tab(text: 'The Sanctuary'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildMessagesTab(),
              const SanctuaryTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view messages.', style: TextStyle(color: Colors.white54)));
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredChats.length,
            itemBuilder: (context, index) {
              final chat = _filteredChats[index];
              return _buildChatTile(chat);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    final bool isUnread = chat['unread'] > 0;
    final bool isOnline = chat['is_online'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DirectMessageScreen(
                partnerId: chat['id']!,
                partnerUsername: chat['username']!,
                badgeType: chat['badge'],
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnread ? Colors.white.withAlpha(20) : Colors.black.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnread ? AppTheme.primaryPurple.withAlpha(100) : Colors.white.withAlpha(10),
                ),
              ),
              child: Row(
                children: [
                  // Avatar with Online Indicator
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isUnread 
                              ? const LinearGradient(colors: [AppTheme.accentGold, AppTheme.primaryPurple])
                              : null,
                          color: isUnread ? null : AppTheme.surfaceDark,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isUnread ? 2.0 : 0.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppTheme.backgroundDark,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: IchthysIcon(color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.backgroundDark, width: 2),
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Message Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              chat['username']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (chat['badge'] != null) ...[
                              const SizedBox(width: 4),
                              InteractiveVerifiedBadge(type: chat['badge'], size: 14),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat['last_message']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnread ? Colors.white : Colors.white54,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Time & Unread Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat['time'],
                        style: TextStyle(
                          color: isUnread ? AppTheme.accentGold : Colors.white30,
                          fontSize: 12,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat['unread'].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
