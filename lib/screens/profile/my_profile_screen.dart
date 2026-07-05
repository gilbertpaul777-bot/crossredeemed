import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import '../home/single_video_screen.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';
import 'package:cross_redeemed/screens/messages/verified_church_screen.dart';
import 'package:cross_redeemed/widgets/interactive_verified_badge.dart';
import 'package:cross_redeemed/screens/messages/inbox_screen.dart';
import 'package:cross_redeemed/screens/settings/settings_screen.dart';
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? get _user => Supabase.instance.client.auth.currentUser;
  
  // Profile Data
  String _username = 'User';
  String _bio = '';
  String? _avatarUrl;
  final String _ministryRole = 'Believer'; // Could be fetched from DB later
  
  // Stats
  final int _followingCount = 0;
  final int _followersCount = 0;
  final int _likesCount = 0;

  // Video Lists
  List<dynamic> _myPosts = [];
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
    _fetchMyPosts();
  }

  Future<void> _loadProfileData() async {
    final cachedUser = _user;
    if (cachedUser != null) {
      setState(() {
        _username = cachedUser.userMetadata?['username'] ?? cachedUser.email?.split('@')[0] ?? 'User';
        _bio = cachedUser.userMetadata?['bio'] ?? '';
        _avatarUrl = cachedUser.userMetadata?['avatar_url'];
      });
    }
    
    try {
      final response = await Supabase.instance.client.auth.getUser();
      final freshUser = response.user;
      if (freshUser != null && mounted) {
        setState(() {
          _username = freshUser.userMetadata?['username'] ?? freshUser.email?.split('@')[0] ?? 'User';
          _bio = freshUser.userMetadata?['bio'] ?? '';
          _avatarUrl = freshUser.userMetadata?['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching fresh user data: $e');
    }
  }

  Future<void> _fetchMyPosts() async {
    final user = _user;
    if (user == null) {
      if (mounted) setState(() => _isLoadingPosts = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select('*, profiles:user_id(username, avatar_url)')
          .eq('user_id', user.id)
          .eq('status', 'ready')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _myPosts = response;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPosts = false);
      debugPrint('Error fetching posts: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 480,
              pinned: true,
              backgroundColor: AppTheme.surfaceDark,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Cover Banner Image
                    Positioned.fill(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=2000&auto=format&fit=crop', // Faith-based aesthetic (nature/mountains)
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                      ),
                    ),
                    // Nebula Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.nebulaGradient,
                          color: AppTheme.backgroundDark.withAlpha(100), // Mix in darkness
                        ),
                        // Soften the gradient over the image
                        foregroundDecoration: BoxDecoration(
                          color: AppTheme.backgroundDark.withAlpha(150),
                        ),
                      ),
                    ),
                    
                    // Action Buttons (Top Right)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.mail_outline, color: Colors.white, size: 28),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen()));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Profile Content
                    SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildAvatarSection(),
                          const SizedBox(height: 16),
                          _buildIdentitySection(),
                          const SizedBox(height: 16),
                          _buildStatsSection(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withAlpha(30)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.format_quote, color: AppTheme.accentGold, size: 20),
                                      const SizedBox(height: 8),
                                      Text(
                                        _bio.isNotEmpty ? _bio : 'Add a bio to share your testimony...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _bio.isNotEmpty ? Colors.white : Colors.white54, 
                                          fontSize: 15, 
                                          height: 1.5,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: 'Georgia', // Elegant serif font
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryPurple,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_view_outlined)),
                    Tab(icon: Icon(Icons.favorite_border)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVideoGrid(),
            _buildEmptyState('No liked videos yet.', Icons.favorite_border),
            _buildEmptyState('No saved videos yet.', Icons.bookmark_border),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.accentGold, AppTheme.primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withAlpha(100),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0), // Ring thickness
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundDark,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) as ImageProvider : null,
            child: _avatarUrl == null ? const IchthysIcon(size: 45, color: Colors.white54) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '@$_username',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(width: 6),
            const InteractiveVerifiedBadge(type: BadgeType.user, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        // Badges Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ministry Role Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryPurple),
              ),
              child: Text(_ministryRole, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            // Home Church Tag
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VerifiedChurchScreen(
                      churchName: 'Grace Fellowship',
                      denomination: 'Non-Denominational',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentGold.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.church, color: AppTheme.accentGold, size: 14),
                    const SizedBox(width: 4),
                    const Text('Grace Fellowship', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const InteractiveVerifiedBadge(type: BadgeType.church, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(50), width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Following', _followingCount),
                _buildStatColumn('Followers', _followersCount),
                _buildStatColumn('Likes', _likesCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            await _loadProfileData(); 
          },
          child: Container(
            width: 160,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryPurple, Color(0xFF6A1B9A)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryPurple.withAlpha(80), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            alignment: Alignment.center,
            child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share Profile coming soon!')));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGrid() {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
    }
    
    if (_myPosts.isEmpty) {
      return _buildEmptyState(
        'Share your testimony with the world.', 
        Icons.video_call,
        buttonText: 'Create Video',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video creation coming soon!')),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75, 
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _myPosts.length,
      itemBuilder: (context, index) {
        final post = _myPosts[index];
        final videoUrl = post['video_url'] as String?;
        final postId = post['id']?.toString();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (postId != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SingleVideoScreen(postId: postId)));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (videoUrl != null)
                  Container(
                    color: Colors.black,
                    child: VideoThumbnail(videoUrl: videoUrl, uniqueId: postId ?? index.toString()),
                  )
                else
                  Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.video_file, color: Colors.white24, size: 40),
                  ),
                  
                // Intercept touches and provide gradient for text
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(180),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4],
                      )
                    ),
                  ),
                ),
                
                const Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_outlined, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('0', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon, {String? buttonText, VoidCallback? onPressed}) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(20), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                Text(
                  message, 
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                if (buttonText != null && onPressed != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundDark,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class VideoThumbnail extends StatefulWidget {
  final String videoUrl;
  final String uniqueId;
  const VideoThumbnail({super.key, required this.videoUrl, required this.uniqueId});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.setVolume(0.0);
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.open(Media(widget.videoUrl), play: false).then((_) {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!_isInitialized) return;
    
    // Play if > 50% visible, otherwise pause
    if (info.visibleFraction > 0.5) {
      if (!_isPlaying) {
        _player.play();
        _isPlaying = true;
      }
    } else {
      if (_isPlaying) {
        _player.pause();
        _isPlaying = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_${widget.uniqueId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: _isInitialized 
        ? SizedBox.expand(
            child: Video(
              controller: _controller,
              fit: BoxFit.cover,
              controls: NoVideoControls,
            ),
          )
        : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)),
    );
  }
}
