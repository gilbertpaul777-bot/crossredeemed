import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/bible_service.dart';
import 'bible_reader_screen.dart';

class ScriptureSearchScreen extends StatefulWidget {
  const ScriptureSearchScreen({super.key});

  @override
  State<ScriptureSearchScreen> createState() => _ScriptureSearchScreenState();
}

class _ScriptureSearchScreenState extends State<ScriptureSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  void _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    
    final results = await BibleService.searchKeyword(query);
    
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search Bible', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.nebulaGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search for a keyword (e.g. "love")',
                            hintStyle: TextStyle(color: Colors.white54),
                            prefixIcon: Icon(Icons.search, color: AppTheme.accentGold),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                                const SizedBox(height: 16),
                                const Text('No results found.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final verse = _results[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    '${verse['book']} ${verse['chapter']}:${verse['verse']}',
                                    style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      verse['text'],
                                      style: const TextStyle(color: Colors.white, height: 1.5),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BibleReaderScreen(
                                          book: verse['book'],
                                          chapter: verse['chapter'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
