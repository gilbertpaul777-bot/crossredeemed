import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'bible_reader_screen.dart';

class SavedVersesScreen extends StatefulWidget {
  const SavedVersesScreen({super.key});

  @override
  State<SavedVersesScreen> createState() => _SavedVersesScreenState();
}

class _SavedVersesScreenState extends State<SavedVersesScreen> {
  List<dynamic> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from('bible_bookmarks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      setState(() {
        _bookmarks = res;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _deleteBookmark(String id) async {
    try {
      await Supabase.instance.client.from('bible_bookmarks').delete().eq('id', id);
      _fetchBookmarks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark removed')));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.nebulaGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
              : _bookmarks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text('No bookmarks yet.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        final b = _bookmarks[index];
                        return Dismissible(
                          key: Key(b['id'].toString()),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteBookmark(b['id']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                '${b['book']} ${b['chapter']}:${b['verse']}',
                                style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  b['text'],
                                  style: const TextStyle(color: Colors.white, height: 1.5),
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BibleReaderScreen(book: b['book'], chapter: b['chapter']),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
