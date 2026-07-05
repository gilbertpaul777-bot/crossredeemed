import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/bible_service.dart';

class AddScriptureOverlayScreen extends StatefulWidget {
  const AddScriptureOverlayScreen({super.key});

  @override
  State<AddScriptureOverlayScreen> createState() => _AddScriptureOverlayScreenState();
}

class _AddScriptureOverlayScreenState extends State<AddScriptureOverlayScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  void _searchBible() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await BibleService.searchKeyword(query);

      setState(() {
        _searchResults = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  void _selectVerse(dynamic verse) {
    // Format: "John 3:16 - For God so loved..."
    final formattedText = '${verse['book']} ${verse['chapter']}:${verse['verse']}\n"${verse['text']}"';
    Navigator.pop(context, formattedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Scripture'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a keyword or verse (e.g., John 3:16)',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.accentGold),
                  onPressed: _searchBible,
                ),
              ),
              onSubmitted: (_) => _searchBible(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(color: AppTheme.primaryPurple)
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No results yet. Try searching!', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final verse = _searchResults[index];
                    return Card(
                      color: AppTheme.surfaceDark,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          '${verse['book']} ${verse['chapter']}:${verse['verse']}',
                          style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          verse['text'],
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectVerse(verse),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
