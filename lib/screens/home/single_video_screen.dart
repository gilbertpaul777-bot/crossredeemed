import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'video_player_item.dart';

class SingleVideoScreen extends StatefulWidget {
  final String postId;

  const SingleVideoScreen({super.key, required this.postId});

  @override
  State<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends State<SingleVideoScreen> {
  Map<String, dynamic>? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    try {
      final res = await Supabase.instance.client
          .from('posts')
          .select('*, profiles:user_id(username, avatar_url)')
          .eq('id', widget.postId)
          .single();
      
      setState(() {
        _post = res;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching single post: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
        : _post == null
          ? const Center(child: Text('Video no longer exists.', style: TextStyle(color: Colors.white)))
          : VideoPlayerItem(post: _post!),
    );
  }
}
