import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class CreateDraftsScreen extends StatefulWidget {
  const CreateDraftsScreen({super.key});

  @override
  State<CreateDraftsScreen> createState() => _CreateDraftsScreenState();
}

class _CreateDraftsScreenState extends State<CreateDraftsScreen> {
  List<dynamic> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDrafts();
  }

  Future<void> _fetchDrafts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'draft')
          .order('created_at', ascending: false);

      setState(() {
        _drafts = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load drafts: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Drafts', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
            : _drafts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.drafts, color: Colors.white54, size: 64),
                        SizedBox(height: 16),
                        Text('No drafts found.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _drafts.length,
                    itemBuilder: (context, index) {
                      final draft = _drafts[index];
                      final date = DateTime.parse(draft['created_at']);
                      return Card(
                        color: AppTheme.surfaceDark,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.video_file, color: Colors.white54),
                          ),
                          title: Text(
                            draft['content']?.isNotEmpty == true ? draft['content'] : 'Untitled Draft',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${date.month}/${date.day}/${date.year} • Tap to resume (Coming soon)',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          onTap: () {
                            // In a full implementation, this would download the draft video or prompt for it
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Draft resumption coming soon!'))
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
