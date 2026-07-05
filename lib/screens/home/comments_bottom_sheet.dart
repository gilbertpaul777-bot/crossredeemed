import 'package:flutter/material.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cross_redeemed/screens/safety/report_dialog.dart';
import 'package:cross_redeemed/screens/auth/guest_modal.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final String tableName;
  
  const CommentsBottomSheet({
    super.key, 
    required this.postId,
    this.tableName = 'post_comments',
  });

  static void show(BuildContext context, {required String postId, String tableName = 'post_comments'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: postId, tableName: tableName),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  List<String> _blockedUserIds = [];

  @override
  void initState() {
    super.initState();
    _fetchBlocks();
  }

  Future<void> _fetchBlocks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final blocks = await Supabase.instance.client.from('user_blocks').select('blocked_id').eq('blocker_id', user.id);
        if (mounted) {
          setState(() {
            _blockedUserIds = (blocks as List).map((b) => b['blocked_id'].toString()).toList();
          });
        }
      } catch (e) {
        debugPrint('Error fetching blocks: $e');
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _commentController.clear();
    
    try {
      await Supabase.instance.client.from(widget.tableName).insert({
        'post_id': widget.postId,
        'user_id': user.id,
        'content': text,
        'author_username': user.userMetadata?['username'] ?? user.email?.split('@')[0] ?? 'User',
        'author_avatar': user.userMetadata?['avatar_url'],
      });
    } catch (e) {
      debugPrint('Error posting comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Balance for centering
                    const Text('Comments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              
              // Comments List
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: Supabase.instance.client
                      .from(widget.tableName)
                      .stream(primaryKey: ['id'])
                      .eq('post_id', widget.postId)
                      .order('created_at', ascending: false),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }
                    
                    final allComments = snapshot.data ?? [];
                    final comments = allComments.where((c) => !_blockedUserIds.contains(c['user_id'].toString())).toList();

                    if (comments.isEmpty) {
                      return const Center(child: Text('No comments yet. Be the first!', style: TextStyle(color: Colors.white54)));
                    }

                    return ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final username = comment['author_username'] ?? 'User';
                        final avatarUrl = comment['author_avatar'] as String?;
                        final text = comment['content'] ?? '';
                        final likes = comment['likes'] ?? 0;
                        final createdAt = DateTime.tryParse(comment['created_at'] ?? '') ?? DateTime.now();
                        
                        return GestureDetector(
                          onLongPress: () {
                            _showCommentOptions(context, comment);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) as ImageProvider : null,
                                  child: avatarUrl == null ? const IchthysIcon( color: Colors.white, size: 20) : null,
                                ),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(username, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
                                          const SizedBox(width: 8),
                                          Text('· ${timeago.format(createdAt)}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      const SizedBox(height: 8),
                                      const Text('Reply', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Like Button
                                GestureDetector(
                                  onTap: () {
                                    // Liking comments coming soon
                                  },
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.favorite_border,
                                        color: Colors.white54,
                                        size: 18,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('$likes', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
              
              // Input Field
              Container(
                padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomInset > 0 ? bottomInset + 12 : 32),
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundDark,
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[800],
                      child: const IchthysIcon( color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        onSubmitted: (_) => _postComment(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceDark,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _postComment,
                      child: const Icon(Icons.send, color: AppTheme.primaryPurple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentOptions(BuildContext context, Map<String, dynamic> comment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.white),
                title: const Text('Report Comment', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ReportDialog.show(context, reportedUserId: comment['user_id']?.toString());
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('Block User', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(context);
                  _handleBlockUser(context, comment['user_id']?.toString());
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _handleBlockUser(BuildContext context, String? creatorId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      GuestModal.show(context);
      return;
    }

    if (creatorId == null || creatorId == user.id) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Block User?', style: TextStyle(color: Colors.white)),
        content: const Text('You will no longer see comments from this user.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Block', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('user_blocks').insert({
        'blocker_id': user.id,
        'blocked_id': creatorId,
      });

      if (context.mounted) {
        setState(() {
          _blockedUserIds.add(creatorId);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked. Comments hidden.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not block user: $e')));
      }
    }
  }
}
