import 'package:flutter/material.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:cross_redeemed/screens/profile/my_profile_screen.dart' show VideoThumbnail;
import 'package:cross_redeemed/screens/home/single_video_screen.dart';
import 'package:cross_redeemed/screens/home/creator_profile_screen.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';
import 'package:cross_redeemed/widgets/church_map_view.dart';
import 'package:cross_redeemed/screens/messages/verified_church_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _debounce;
  
  final List<String> _tabs = ['Videos', 'Users', 'Local Churches'];
  int _selectedTabIndex = 0;
  bool _isMapView = false;

  bool _isLoading = false;
  List<Map<String, dynamic>> _videoResults = [];
  List<Map<String, dynamic>> _userResults = [];
  List<String> _blockedUserIds = [];

  // Mock Churches
  final List<Map<String, dynamic>> _mockChurches = [
    {
      'id': 'church_1',
      'name': 'Grace Fellowship',
      'denomination': 'Non-Denominational',
      'distance': '1.2 miles away',
    },
    {
      'id': 'church_2',
      'name': 'First Baptist City Center',
      'denomination': 'Baptist',
      'distance': '3.4 miles away',
    },
    {
      'id': 'church_3',
      'name': 'St. Jude Catholic Church',
      'denomination': 'Catholic',
      'distance': '5.0 miles away',
    },
    {
      'id': 'church_4',
      'name': 'Hope Pentecostal',
      'denomination': 'Pentecostal',
      'distance': '7.1 miles away',
    }
  ];
  List<Map<String, dynamic>> _churchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchBlocks();
    _churchResults = List.from(_mockChurches);
  }

  Future<void> _fetchBlocks() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final blocks = await _supabase.from('user_blocks').select('blocked_id').eq('blocker_id', user.id);
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

  final List<String> _trending = [
    'Faith',
    'Trust God',
    'Bible Study',
    'Prayer',
    'Worship',
    'Testimonies',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _videoResults = [];
        _userResults = [];
        _churchResults = List.from(_mockChurches);
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Search Videos (posts table) where description matches query
      final videos = await _supabase
          .from('posts')
          .select()
          .ilike('description', '%$trimmed%')
          .order('created_at', ascending: false)
          .limit(20);

      // 2. Search Users (profiles table) where username matches query
      final users = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$trimmed%')
          .limit(20);

      // Filter out blocked users
      final filteredVideos = videos.where((v) => !_blockedUserIds.contains(v['user_id'].toString())).toList();
      final filteredUsers = users.where((u) => !_blockedUserIds.contains(u['id'].toString())).toList();

      final filteredChurches = _mockChurches.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final denom = (c['denomination'] as String).toLowerCase();
        final lowerTrimmed = trimmed.toLowerCase();
        return name.contains(lowerTrimmed) || denom.contains(lowerTrimmed);
      }).toList();

      setState(() {
        _videoResults = List<Map<String, dynamic>>.from(filteredVideos);
        _userResults = List<Map<String, dynamic>>.from(filteredUsers);
        _churchResults = filteredChurches;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Search Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ..._trending.map((topic) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text(topic, style: const TextStyle(color: Colors.white, fontSize: 15)),
            trailing: const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 18),
            onTap: () {
              _searchCtrl.text = topic;
              _performSearch(topic);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildVideoResults() {
    if (_videoResults.isEmpty) {
      return const Center(
        child: Text('No videos found.', style: TextStyle(color: Colors.white54)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: _videoResults.length,
      itemBuilder: (context, index) {
        final video = _videoResults[index];
        final videoUrl = video['video_url'] as String?;
        final postId = video['id']?.toString();
        
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
                  Center(
                    child: Icon(Icons.play_circle_outline, color: Colors.white.withValues(alpha: 0.5), size: 40),
                  ),
                
                // Intercept touches so the native Web <video> player doesn't steal them
                Positioned.fill(
                  child: Container(color: Colors.transparent),
                ),
                
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    video['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10, shadows: [
                      Shadow(color: Colors.black, blurRadius: 4)
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) {
      return const Center(
        child: Text('No users found.', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        final avatarUrl = user['avatar_url'] as String?;
        final username = user['username'] ?? 'Believer';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryPurple,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const IchthysIcon( color: Colors.white) : null,
          ),
          title: Text('@$username', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: ElevatedButton(
            onPressed: () {
              final targetUserId = user['id']?.toString();
              if (targetUserId != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreatorProfileScreen(creatorId: targetUserId)));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('View', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  Widget _buildChurchView() {
    return Column(
      children: [
        // Map Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_churchResults.length} Churches Near You',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isMapView = !_isMapView),
                icon: Icon(_isMapView ? Icons.list : Icons.map, size: 18),
                label: Text(_isMapView ? 'List View' : 'Map View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isMapView ? ChurchMapView(churches: _churchResults) : _buildChurchList(),
        ),
      ],
    );
  }

  Widget _buildChurchList() {
    if (_churchResults.isEmpty) {
      return const Center(child: Text('No churches found nearby.', style: TextStyle(color: Colors.white54)));
    }
    return ListView.separated(
      itemCount: _churchResults.length,
      separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final church = _churchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            child: Icon(Icons.church, color: Colors.white),
          ),
          title: Row(
            children: [
              Flexible(child: Text(church['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
              Image.asset('assets/images/church_verified_badge.png', height: 24, width: 24),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(church['denomination'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(church['distance'], style: const TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerifiedChurchScreen(
                  churchName: church['name'],
                  denomination: church['denomination'],
                  churchData: church,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back button and Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search CrossRedeemed',
                          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          suffixIcon: _searchCtrl.text.isNotEmpty 
                            ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  _performSearch('');
                                },
                                child: const Icon(Icons.close, color: Colors.white54, size: 16),
                              )
                            : null,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // Tab Bar
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryPurple : Colors.white54,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            
            // Main Content Area
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
                : _selectedTabIndex == 2
                    ? _buildChurchView()
                    : _searchCtrl.text.trim().isEmpty
                      ? _buildEmptyState()
                      : (_selectedTabIndex == 0 ? _buildVideoResults() : _buildUserResults()),
            ),
          ],
        ),
      ),
    );
  }
}
