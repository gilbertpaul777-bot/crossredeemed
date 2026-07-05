import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'single_video_screen.dart';
import '../profile/my_profile_screen.dart' show VideoThumbnail;
import '../safety/report_dialog.dart';
import '../auth/guest_modal.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String creatorId;

  const CreatorProfileScreen({super.key, required this.creatorId});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _username = 'User';
  String _bio = '';
  String? _avatarUrl;
  
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _fetchCreatorData();
  }

  Future<void> _fetchCreatorData() async {
    try {
      // 1. Fetch profile info
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', widget.creatorId)
          .maybeSingle();

      if (profile != null) {
        _username = profile['username'] ?? 'User';
        _bio = profile['bio'] ?? '';
        _avatarUrl = profile['avatar_url'];
      }

      // 2. Fetch their videos
      final posts = await _supabase
          .from('posts')
          .select()
          .eq('user_id', widget.creatorId)
          .eq('status', 'ready')
          .order('created_at', ascending: false);

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching creator data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showCreatorOptions() {
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
                title: const Text('Report User', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ReportDialog.show(context, reportedUserId: widget.creatorId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('Block User', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _handleBlockUser();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBlockUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      GuestModal.show(context);
      return;
    }

    if (widget.creatorId == user.id) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Block User?', style: TextStyle(color: Colors.white)),
        content: const Text('You will no longer see content from this user.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Block', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _supabase.from('user_blocks').insert({
        'blocker_id': user.id,
        'blocked_id': widget.creatorId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
        Navigator.pop(context); // Go back to search/previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not block user: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
      );
    }

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
                  leading: const BackButton(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: _showCreatorOptions,
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Cover Banner Image
                        Positioned.fill(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=2000&auto=format&fit=crop', // Faith-based aesthetic
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                          ),
                        ),
                        // Nebula Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.nebulaGradient,
                              color: AppTheme.backgroundDark.withAlpha(100),
                            ),
                            foregroundDecoration: BoxDecoration(
                              color: AppTheme.backgroundDark.withAlpha(150),
                            ),
                          ),
                        ),

                        // Profile Content
                        SafeArea(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _buildAvatarSection(),
                              const SizedBox(height: 16),
                              Text(
                                '@$_username',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 16),
                              _buildStatsSection(),
                              const SizedBox(height: 16),
                              _buildActionButtons(),
                              const SizedBox(height: 16),
                              _buildBioSection(),
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
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_view_outlined)),
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
        padding: const EdgeInsets.all(3.0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundDark,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
            child: _avatarUrl == null ? const IchthysIcon(size: 45, color: Colors.white54) : null,
          ),
        ),
      ),
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
                _buildStatColumn('Following', '0'),
                _buildStatColumn('Followers', '0'),
                _buildStatColumn('Likes', '0'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Following coming soon!')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Padding(
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
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
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

  Widget _buildVideoGrid() {
    if (_posts.isEmpty) {
      return _buildEmptyState('No videos yet.', Icons.video_library_outlined);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final videoUrl = post['video_url'];
        final postId = post['id']?.toString();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (postId != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SingleVideoScreen(postId: postId)));
            }
          },
          child: Container(
            color: Colors.black45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (videoUrl != null)
                  VideoThumbnail(videoUrl: videoUrl, uniqueId: postId ?? index.toString())
                else
                  const Center(child: Icon(Icons.play_circle_outline, color: Colors.white54, size: 40)),
                
                Positioned.fill(
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
        );
      },
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
