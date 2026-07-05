import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'bible_reader_screen.dart';
import 'chapter_view_screen.dart';
import 'scripture_search_screen.dart';
import 'saved_verses_screen.dart';
import 'notes_screen.dart';
import 'reading_history_screen.dart';
import 'cross_references_screen.dart';
import 'bible_settings_modal.dart';


class BibleHomeScreen extends StatelessWidget {
  const BibleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses MainShell background
      appBar: AppBar(
        title: const Text('KJV', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              BibleSettingsModal.show(context);
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header Text
                const Text(
                  'Let the Word of God\ntransform you.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 30),

                // Verse of the Day Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryPurple, Color(0xFF6B46C1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny, color: AppTheme.accentGold, size: 20),
                          const SizedBox(width: 8),
                          Text('Verse of the Day', style: TextStyle(color: AppTheme.accentGold.withValues(alpha: 0.9), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '"For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life."',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('John 3:16', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Continue Reading
                const Text(
                  'Continue Reading',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BibleReaderScreen(book: 'John', chapter: 3),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'John 3',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_forward_ios, color: AppTheme.accentGold, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Quick Access
                const Text(
                  'Quick Access',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                  GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildQuickAccessButton(context, 'Search', Icons.search, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScriptureSearchScreen()));
                    }),
                    _buildQuickAccessButton(context, 'Notes', Icons.notes, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()));
                    }),
                    _buildQuickAccessButton(context, 'History', Icons.history, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingHistoryScreen()));
                    }),
                    _buildQuickAccessButton(context, 'Bookmarks', Icons.bookmark_border, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedVersesScreen()));
                    }),
                  ],
                ),
            
            const SizedBox(height: 30),
            
            // Premium Tools
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildPremiumTool(context, 'Matthew Henry Commentary', Icons.menu_book),
                  const Divider(color: Colors.white10, height: 1),
                  _buildPremiumTool(context, "Strong's Concordance", Icons.translate),
                  const Divider(color: Colors.white10, height: 1),
                  _buildPremiumTool(context, 'Cross References', Icons.compare_arrows),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // All Books Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChapterViewScreen(), // Re-using this as the main book selector
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.library_books, color: Colors.white),
                label: const Text('Browse All Books', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTool(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentGold),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
      onTap: () {
        if (title == 'Matthew Henry Commentary') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChapterViewScreen(isForCommentary: true),
            ),
          );
        } else if (title == "Strong's Concordance") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChapterViewScreen(isForStrongs: true),
            ),
          );
        } else if (title == 'Cross References') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrossReferencesScreen(baseBook: 'John', baseChapter: 3, baseVerse: 16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title coming soon')));
        }
      },
    );
  }
}
