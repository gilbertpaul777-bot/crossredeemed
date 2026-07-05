import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_redeemed/screens/auth/guest_modal.dart';
import 'package:cross_redeemed/screens/home/comments_bottom_sheet.dart';
import 'package:cross_redeemed/screens/safety/report_dialog.dart';

import 'package:flutter/services.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';

class VideoPlayerItem extends StatefulWidget {
  final Map<String, dynamic> post;
  const VideoPlayerItem({super.key, required this.post});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isVisible = false;

  // Engagement State
  int _likesCount = 0;
  int _commentsCount = 0;
  int _bookmarksCount = 0;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.post['video_url'] as String?;
    if (videoUrl == null) {
      _hasError = true;
      return;
    }
    
    _fetchEngagementStats();

    try {
      _player = Player();
      _controller = VideoController(_player);
      
      _player.stream.playing.listen((playing) {
        if (mounted) {
          setState(() {
            _isPlaying = playing;
          });
        }
      });
      
      _player.setPlaylistMode(PlaylistMode.loop);
      _player.setVolume(0.0); // Mute to allow autoplay on web
      
      _player.open(Media(videoUrl), play: false).then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          if (_isVisible) {
            _player.play();
            _isPlaying = true;
          }
        }
      }).catchError((e) {
        debugPrint('Video error for $videoUrl: $e');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _fetchEngagementStats() async {
    final postId = widget.post['id'];
    if (postId == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      final client = Supabase.instance.client;
      // Using .select() since we need to check if currentUser has liked
      final likesRes = await client.from('post_likes').select('user_id').eq('post_id', postId);
      final commentsRes = await client.from('post_comments').select('id').eq('post_id', postId);
      final bookmarksRes = await client.from('post_bookmarks').select('user_id').eq('post_id', postId);

      if (!mounted) return;

      setState(() {
        _likesCount = likesRes.length;
        _commentsCount = commentsRes.length;
        _bookmarksCount = bookmarksRes.length;

        if (userId != null) {
          _isLiked = likesRes.any((r) => r['user_id'] == userId);
          _isBookmarked = bookmarksRes.any((r) => r['user_id'] == userId);
        }
      });
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.post['content'] ?? '';
    final postId = widget.post['id']?.toString();
    final videoUrl = widget.post['video_url']?.toString();
    
    return VisibilityDetector(
      key: Key(postId ?? videoUrl ?? 'fallback_video_key'),
      onVisibilityChanged: (info) {
        _isVisible = info.visibleFraction > 0.5;
        if (_isInitialized) {
          if (_isVisible) {
            _player.play();
            _isPlaying = true;
          } else {
            _player.pause();
            _isPlaying = false;
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Layer
          if (_isInitialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_player.state.volume == 0.0) {
                    _player.setVolume(100.0); // First tap unmutes the video
                  } else {
                    if (_isPlaying) {
                      _player.pause();
                      _isPlaying = false;
                    } else {
                      _player.play();
                      _isPlaying = true;
                    }
                  }
                });
              },
              child: Container(
                color: Colors.black,
                child: SizedBox.expand(
                  child: Video(
                    controller: _controller,
                    fit: BoxFit.contain,
                    controls: NoVideoControls,
                  ),
                ),
              ),
            )
          else if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  'Error loading video\nURL: $videoUrl\nError: $_errorMessage', 
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          
          // 2. Play/Pause Overlay Icon
          if (_isInitialized && !_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white54),
            ),

          // 3. Scripture Overlay (If present in database)
          if (widget.post['scripture_overlay'] != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2), // AppTheme.accentGold
                ),
                child: Text(
                  widget.post['scripture_overlay'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          // 4. Gradient Overlay for readability
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(26), // 0.1 opacity
                      Colors.black.withAlpha(179), // 0.7 opacity
                    ],
                    stops: const [0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Bottom Left Info Stack
          Positioned(
            bottom: 24,
            left: 16,
            right: 80, // Leave room for right stack
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.post['profiles']?['username'] ?? 'User'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                ),
                const SizedBox(height: 8),
                Text(
                  caption,
                  style: const TextStyle(color: Colors.white, fontSize: 15, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Original Sound - ${widget.post['profiles']?['username'] ?? 'User'}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 5. Engagement Buttons (Right Side)
          Positioned(
            right: 12,
            bottom: 24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Creator Avatar with + Button
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        color: Colors.grey[800],
                        image: widget.post['profiles']?['avatar_url'] != null
                            ? DecorationImage(
                                image: NetworkImage(widget.post['profiles']['avatar_url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.post['profiles']?['avatar_url'] == null 
                          ? const IchthysIcon(size: 32, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: -8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF7B1FA2), // AppTheme.primaryPurple
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildEngagementAction(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  iconColor: _isLiked ? Colors.red : Colors.white,
                  label: _formatCount(_likesCount),
                  onTap: () => _handleEngagementAction(context, 'like'),
                ),
                const SizedBox(height: 20),
                _buildEngagementAction(
                  icon: Icons.chat_bubble,
                  iconColor: Colors.white,
                  label: _formatCount(_commentsCount),
                  onTap: () => _handleEngagementAction(context, 'comment'),
                ),
                const SizedBox(height: 20),
                _buildEngagementAction(
                  icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  iconColor: _isBookmarked ? const Color(0xFFFACC15) : Colors.white, // AppTheme.accentGold
                  label: _formatCount(_bookmarksCount),
                  onTap: () => _handleEngagementAction(context, 'bookmark'),
                ),
                const SizedBox(height: 20),
                _buildEngagementAction(
                  icon: Icons.reply, // Reply icon looks like a share arrow in Flutter
                  iconColor: Colors.white,
                  label: 'Share',
                  onTap: () async {
                    final url = widget.post['video_url'];
                    if (url != null) {
                      try {
                        // ignore: deprecated_member_use
                        await Share.share('Check out this amazing video on CrossRedeemed!\n\n$url');
                      } catch (e) {
                        Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')));
                        }
                      }
                    }
                  },
                ),
                if (Supabase.instance.client.auth.currentUser?.id != widget.post['user_id']) ...[
                  const SizedBox(height: 20),
                  _buildEngagementAction(
                    icon: Icons.flag_outlined,
                    iconColor: Colors.white,
                    label: 'Report',
                    onTap: () {
                      final postId = widget.post['id']?.toString();
                      final creatorId = widget.post['user_id']?.toString();
                      ReportDialog.show(context, reportedPostId: postId, reportedUserId: creatorId);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildEngagementAction(
                    icon: Icons.block,
                    iconColor: Colors.redAccent,
                    label: 'Block',
                    onTap: () => _handleBlockUser(context),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  _buildEngagementAction(
                    icon: Icons.delete_outline,
                    iconColor: Colors.redAccent,
                    label: 'Delete',
                    onTap: () => _handleDeletePost(context),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleBlockUser(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      GuestModal.show(context);
      return;
    }

    final creatorId = widget.post['user_id']?.toString();
    if (creatorId == null || creatorId == user.id) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // AppTheme.surfaceDark
        title: const Text('Block User?', style: TextStyle(color: Colors.white)),
        content: const Text('You will no longer see videos from this creator.', style: TextStyle(color: Colors.white70)),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked. Please refresh your feed.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not block user: $e')));
      }
    }
  }

  void _handleDeletePost(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Video?', style: TextStyle(color: Colors.white)),
        content: const Text('This video will be permanently removed.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('posts').delete().eq('id', widget.post['id']);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video deleted. Please refresh your feed.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete video: $e')));
      }
    }
  }

  void _handleEngagementAction(BuildContext context, String actionType) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      GuestModal.show(context);
      return;
    }

    final postId = widget.post['id'];
    if (postId == null) return;
    
    final client = Supabase.instance.client;

    if (actionType == 'comment') {
      CommentsBottomSheet.show(context, postId: postId);
    } else if (actionType == 'like') {
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
      try {
        if (_isLiked) {
          await client.from('post_likes').insert({'post_id': postId, 'user_id': user.id});
        } else {
          await client.from('post_likes').delete().eq('post_id', postId).eq('user_id', user.id);
        }
      } catch (e) {
        setState(() {
          _isLiked = !_isLiked;
          _likesCount += _isLiked ? 1 : -1;
        });
      }
    } else if (actionType == 'bookmark') {
      setState(() {
        _isBookmarked = !_isBookmarked;
        _bookmarksCount += _isBookmarked ? 1 : -1;
      });
      try {
        if (_isBookmarked) {
          await client.from('post_bookmarks').insert({'post_id': postId, 'user_id': user.id});
        } else {
          await client.from('post_bookmarks').delete().eq('post_id', postId).eq('user_id', user.id);
        }
      } catch (e) {
        setState(() {
          _isBookmarked = !_isBookmarked;
          _bookmarksCount += _isBookmarked ? 1 : -1;
        });
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}m';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  Widget _buildEngagementAction({required IconData icon, required Color iconColor, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 36, shadows: const [Shadow(color: Colors.black54, blurRadius: 8)]),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
        ],
      ),
    );
  }
}
