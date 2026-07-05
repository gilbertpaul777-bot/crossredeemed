import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'video_player_item.dart';
import 'search_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  bool _isForYou = true; // true for "For You", false for "Following"

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    
    List<String> blockedUserIds = [];
    if (user != null) {
      try {
        final blocks = await client.from('user_blocks').select('blocked_id').eq('blocker_id', user.id);
        blockedUserIds = (blocks as List).map((b) => b['blocked_id'].toString()).toList();
      } catch (e) {
        debugPrint('Error fetching blocks: $e');
      }
    }

    final posts = await client
        .from('posts')
        .select('*, profiles:user_id(username, avatar_url)')
        .eq('status', 'ready')
        .order('created_at', ascending: false);
        
    if (blockedUserIds.isEmpty) return posts;
    
    return posts.where((post) {
      return !blockedUserIds.contains(post['user_id'].toString());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let main_shell nebula show through
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            color: Colors.black, // Feed background
            child: Stack(
        children: [
          // The Feed
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return const Center(child: Text('No videos yet. Be the first to post!', style: TextStyle(color: Colors.white)));
              }

              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return VideoPlayerItem(
                    post: post,
                  );
                },
              );
            },
          ),
          
          // Top Navigation Bar (Following | For You | Search)
          Positioned(
            top: 50, // SafeArea spacing
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Placeholder for layout balance
                  const SizedBox(width: 48), 
                  
                  // Center Tabs
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isForYou = false),
                        child: Text(
                          'Following',
                          style: TextStyle(
                            color: !_isForYou ? Colors.white : Colors.white60,
                            fontWeight: !_isForYou ? FontWeight.bold : FontWeight.w500,
                            fontSize: 18,
                            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('|', style: TextStyle(color: Colors.white60, fontSize: 18, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isForYou = true),
                        child: Text(
                          'For You',
                          style: TextStyle(
                            color: _isForYou ? Colors.white : Colors.white60,
                            fontWeight: _isForYou ? FontWeight.bold : FontWeight.w500,
                            fontSize: 18,
                            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Search Icon
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 28, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                    },
                  ),
                ],
              ),
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
