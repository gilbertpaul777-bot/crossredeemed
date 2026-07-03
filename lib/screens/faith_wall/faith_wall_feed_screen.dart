import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cross_redeemed/screens/auth/guest_modal.dart';
import 'package:cross_redeemed/screens/home/comments_bottom_sheet.dart';
import 'package:cross_redeemed/screens/safety/report_dialog.dart';
import '../../theme/app_theme.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';
import 'package:cross_redeemed/widgets/interactive_verified_badge.dart';

class FaithWallFeedScreen extends StatefulWidget {
  const FaithWallFeedScreen({super.key});

  @override
  State<FaithWallFeedScreen> createState() => _FaithWallFeedScreenState();
}

class _FaithWallFeedScreenState extends State<FaithWallFeedScreen> {
  final supabase = Supabase.instance.client;
  List<String> _blockedUserIds = [];
  List<String> _followedUserIds = [];

  @override
  void initState() {
    super.initState();
    _fetchBlocks();
    _fetchFollows();
  }

  Future<void> _fetchBlocks() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final blocks = await supabase
            .from('user_blocks')
            .select('blocked_id')
            .eq('blocker_id', user.id);
        if (mounted) {
          setState(() {
            _blockedUserIds = (blocks as List)
                .map((b) => b['blocked_id'].toString())
                .toList();
          });
        }
      } catch (e) {
        debugPrint('Error fetching blocks: $e');
      }
    }
  }

  Future<void> _fetchFollows() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final follows = await supabase
            .from('user_follows')
            .select('following_id')
            .eq('follower_id', user.id);
        if (mounted) {
          setState(() {
            _followedUserIds = (follows as List)
                .map((f) => f['following_id'].toString())
                .toList();
          });
        }
      } catch (e) {
        debugPrint('Error fetching follows: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let MainShell background show
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withAlpha(50)),
            ),
          ),
          title: const Text(
            'Faith Wall',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryPurple,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedStream(isFollowing: false),
            _buildFeedStream(isFollowing: true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreatePostModal(context),
          backgroundColor: AppTheme.accentGold,
          child: const Icon(Icons.edit, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFeedStream({required bool isFollowing}) {
    // If following feed and not following anyone, return empty state immediately
    if (isFollowing && _followedUserIds.isEmpty) {
      return _buildEmptyState(message: "You aren't following anyone yet!");
    }

    final baseQuery = supabase
        .from('faith_wall_posts')
        .stream(primaryKey: ['id']);
    final stream = isFollowing
        ? baseQuery
              .inFilter('user_id', _followedUserIds)
              .order('created_at', ascending: false)
        : baseQuery.order('created_at', ascending: false);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentGold),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading posts: ${snapshot.error}',
              style: const TextStyle(color: Colors.white54),
            ),
          );
        }

        final allPosts = snapshot.data ?? [];
        final posts = allPosts
            .where(
              (post) => !_blockedUserIds.contains(post['user_id'].toString()),
            )
            .toList();

        if (posts.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return FaithWallPostCard(post: post)
                .animate(delay: (index * 50).ms)
                .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({String message = 'No posts yet.'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum_outlined, color: Colors.white24, size: 80),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share!',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showCreatePostModal(BuildContext context) {
    final TextEditingController contentCtrl = TextEditingController();
    String selectedType = 'prayer_request';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    border: const Border(
                      top: BorderSide(color: Colors.white24, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Create Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withAlpha(40),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedType,
                              dropdownColor: AppTheme.surfaceDark,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'prayer_request',
                                  child: Text('Prayer Request'),
                                ),
                                DropdownMenuItem(
                                  value: 'testimony',
                                  child: Text('Testimony'),
                                ),
                                DropdownMenuItem(
                                  value: 'praise_report',
                                  child: Text('Praise Report'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedType = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Text Area
                        TextField(
                          controller: contentCtrl,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'What is on your heart?',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withAlpha(20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withAlpha(40),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Post Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppTheme.nebulaGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withAlpha(100),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final content = contentCtrl.text.trim();
                              if (content.isEmpty) return;

                              // Disable button while posting
                              setModalState(() {});

                              // Capture Nav/Messenger state for safe async usage
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final navigator = Navigator.of(context);

                              try {
                                final user =
                                    Supabase.instance.client.auth.currentUser;
                                if (user == null) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You must be logged in to post.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                await Supabase.instance.client
                                    .from('faith_wall_posts')
                                    .insert({
                                      'user_id': user.id,
                                      'type': selectedType,
                                      'content': content,
                                      'author_username':
                                          user.userMetadata?['username'] ??
                                          user.email?.split('@')[0] ??
                                          'Believer',
                                      'author_avatar':
                                          user.userMetadata?['avatar_url'],
                                    });

                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Posted successfully!'),
                                  ),
                                );
                              } catch (e) {
                                debugPrint('Error posting: $e');
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Post to Faith Wall',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FaithWallPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const FaithWallPostCard({super.key, required this.post});

  @override
  State<FaithWallPostCard> createState() => _FaithWallPostCardState();
}

class _FaithWallPostCardState extends State<FaithWallPostCard> {
  int _likesCount = 0;
  bool _isLiked = false;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post['likes_count'] ?? 0;
    _commentsCount = widget.post['comments_count'] ?? 0;
    _fetchLikeStatus();
  }

  Future<void> _fetchLikeStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    final postId = widget.post['id'];
    if (user == null || postId == null) return;

    try {
      final res = await Supabase.instance.client
          .from('faith_wall_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _isLiked = res.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error fetching like status: $e');
    }
  }

  Future<void> _handleLike() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      GuestModal.show(context);
      return;
    }

    final postId = widget.post['id'];
    if (postId == null) return;

    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        await Supabase.instance.client.from('faith_wall_likes').insert({
          'post_id': postId,
          'user_id': user.id,
        });
      } else {
        await Supabase.instance.client
            .from('faith_wall_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
      }
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildPostTypeTag(String? type) {
    String label;
    Color color;
    switch (type) {
      case 'prayer_request':
        label = 'Prayer Request';
        color = AppTheme.primaryPurple;
        break;
      case 'testimony':
        label = 'Testimony';
        color = AppTheme.accentGold;
        break;
      case 'praise_report':
        label = 'Praise Report';
        color = Colors.green;
        break;
      default:
        label = 'Post';
        color = Colors.white54;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(150)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.post['content'] ?? '';
    final createdAt =
        DateTime.tryParse(widget.post['created_at'] ?? '') ?? DateTime.now();
    final username = widget.post['author_username'] ?? 'Believer';
    final avatarUrl = widget.post['author_avatar'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withAlpha(15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryPurple,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl) as ImageProvider
                            : null,
                        child: avatarUrl == null
                            ? const IchthysIcon(color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const InteractiveVerifiedBadge(
                                  type: BadgeType.user,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _formatDate(createdAt),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildPostTypeTag(widget.post['type']),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          _showPostOptions(context, widget.post);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLikeActionIcon(
                        '$_likesCount Praying!',
                        _handleLike,
                      ),
                      _buildActionIcon(
                        Icons.chat_bubble_outline,
                        '$_commentsCount',
                        () {
                          final postId = widget.post['id'];
                          if (postId != null) {
                            CommentsBottomSheet.show(
                              context,
                              postId: postId,
                              tableName: 'faith_wall_comments',
                            );
                          }
                        },
                      ),
                      _buildActionIcon(Icons.share_outlined, 'Share', () {}),
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

  Widget _buildLikeActionIcon(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(
                  _isLiked
                      ? Icons.volunteer_activism
                      : Icons.volunteer_activism_outlined,
                  size: 20,
                  color: Colors.white,
                )
                .animate(target: _isLiked ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                )
                .tint(color: _isLiked ? AppTheme.accentGold : Colors.white54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: _isLiked ? AppTheme.accentGold : Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = Colors.white54,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.white),
                title: const Text(
                  'Report Post',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ReportDialog.show(
                    context,
                    reportedPostId: post['id']?.toString(),
                    reportedUserId: post['user_id']?.toString(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text(
                  'Block User',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  _handleBlockUser(context, post['user_id']?.toString());
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
        backgroundColor: const Color(0xFF1E1E1E), // AppTheme.surfaceDark
        title: const Text('Block User?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You will no longer see posts from this user.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User blocked. Please restart the app or refresh the feed.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not block user: $e')));
      }
    }
  }
}
