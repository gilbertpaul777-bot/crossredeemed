import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'bible_reader_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from('bible_notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      setState(() {
        _notes = res;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _deleteNote(String id) async {
    try {
      await Supabase.instance.client.from('bible_notes').delete().eq('id', id);
      _fetchNotes();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted')));
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
        title: const Text('My Notes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              : _notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text('No notes yet.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final n = _notes[index];
                        return Dismissible(
                          key: Key(n['id'].toString()),
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
                          onDismissed: (_) => _deleteNote(n['id']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${n['book']} ${n['chapter']}:${n['verse']}',
                                      style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => BibleReaderScreen(book: n['book'], chapter: n['chapter'])));
                                      },
                                    )
                                  ],
                                ),
                                Text('"${n['verse_text']}"', style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                                const SizedBox(height: 12),
                                const Divider(color: Colors.white10, height: 1),
                                const SizedBox(height: 12),
                                Text(n['note_text'], style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
                              ],
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
