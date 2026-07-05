import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../theme/app_theme.dart';
import '../home/single_video_screen.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Join with profiles to get the actor's username and avatar
      final res = await _supabase
          .from('notifications')
          .select('*, profiles:actor_id(username, avatar_url)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _notifications = res;
        _isLoading = false;
      });

      // Mark all as read
      final unreadIds = res.where((n) => n['is_read'] == false).map((n) => n['id']).toList();
      if (unreadIds.isNotEmpty) {
        await _supabase.from('notifications').update({'is_read': true}).inFilter('id', unreadIds);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildIcon(String type) {
    switch (type) {
      case 'post_like':
        return const Icon(Icons.favorite, color: Colors.red, size: 24);
      case 'post_comment':
        return const Icon(Icons.chat_bubble, color: AppTheme.primaryPurple, size: 24);
      case 'faith_wall_like':
        return const Icon(Icons.volunteer_activism, color: AppTheme.accentGold, size: 24);
      default:
        return const Icon(Icons.notifications, color: Colors.white, size: 24);
    }
  }

  String _buildMessage(String type, String username) {
    switch (type) {
      case 'post_like':
        return '@$username liked your video.';
      case 'post_comment':
        return '@$username commented on your video.';
      case 'faith_wall_like':
        return '@$username is praying for your Faith Wall post.';
      default:
        return '@$username interacted with you.';
    }
  }

  void _handleTap(Map<String, dynamic> notification) {
    final postId = notification['post_id'];
    if (postId == null) return;

    final type = notification['type'] as String;

    if (type == 'post_like' || type == 'post_comment') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SingleVideoScreen(postId: postId),
        ),
      );
    } else if (type == 'faith_wall_like') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Routing to specific Faith Wall post coming soon!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppTheme.primaryPurple,
                  backgroundColor: AppTheme.surfaceDark,
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final profile = n['profiles'] ?? {};
                      final username = profile['username'] ?? 'Someone';
                      final avatarUrl = profile['avatar_url'];
                      final isRead = n['is_read'] == true;
                      final date = DateTime.parse(n['created_at']);

                      return Container(
                        color: isRead ? Colors.transparent : AppTheme.primaryPurple.withValues(alpha: 0.1),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.surfaceDark,
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null ? const IchthysIcon( color: Colors.white54) : null,
                              ),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.backgroundDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _buildIcon(n['type']),
                                ),
                              )
                            ],
                          ),
                          title: Text(
                            _buildMessage(n['type'], username),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          subtitle: Text(
                            timeago.format(date),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          onTap: () => _handleTap(n),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'No Activity Yet',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'When someone likes or comments\non your posts, it will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
