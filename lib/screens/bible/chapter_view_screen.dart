import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'bible_reader_screen.dart';
import 'commentary_screen.dart';
import 'concordance_screen.dart';

class ChapterViewScreen extends StatefulWidget {
  final bool isForCommentary;
  final bool isForStrongs;
  const ChapterViewScreen({super.key, this.isForCommentary = false, this.isForStrongs = false});

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  // Hardcoded map of KJV Books and their total chapters for instant UI
  final Map<String, int> _oldTestament = {
    'Genesis': 50, 'Exodus': 40, 'Leviticus': 27, 'Numbers': 36, 'Deuteronomy': 34,
    'Joshua': 24, 'Judges': 21, 'Ruth': 4, '1 Samuel': 31, '2 Samuel': 24,
    '1 Kings': 22, '2 Kings': 25, '1 Chronicles': 29, '2 Chronicles': 36,
    'Ezra': 10, 'Nehemiah': 13, 'Esther': 10, 'Job': 42, 'Psalms': 150,
    'Proverbs': 31, 'Ecclesiastes': 12, 'Song of Solomon': 8, 'Isaiah': 66,
    'Jeremiah': 52, 'Lamentations': 5, 'Ezekiel': 48, 'Daniel': 12,
    'Hosea': 14, 'Joel': 3, 'Amos': 9, 'Obadiah': 1, 'Jonah': 4,
    'Micah': 7, 'Nahum': 3, 'Habakkuk': 3, 'Zephaniah': 3, 'Haggai': 2,
    'Zechariah': 14, 'Malachi': 4,
  };

  final Map<String, int> _newTestament = {
    'Matthew': 28, 'Mark': 16, 'Luke': 24, 'John': 21, 'Acts': 28,
    'Romans': 16, '1 Corinthians': 16, '2 Corinthians': 13, 'Galatians': 6,
    'Ephesians': 6, 'Philippians': 4, 'Colossians': 4, '1 Thessalonians': 5,
    '2 Thessalonians': 3, '1 Timothy': 6, '2 Timothy': 4, 'Titus': 3,
    'Philemon': 1, 'Hebrews': 13, 'James': 5, '1 Peter': 5, '2 Peter': 3,
    '1 John': 5, '2 John': 1, '3 John': 1, 'Jude': 1, 'Revelation': 22,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Select Book & Chapter', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: const TabBar(
              indicatorColor: AppTheme.primaryPurple,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Old Testament'),
                Tab(text: 'New Testament'),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: TabBarView(
                children: [
              _buildBookList(_oldTestament),
              _buildBookList(_newTestament),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(Map<String, int> books) {
    return ListView.builder(
      itemCount: books.keys.length,
      itemBuilder: (context, index) {
        String bookName = books.keys.elementAt(index);
        int chapters = books[bookName]!;

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              bookName,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            iconColor: AppTheme.accentGold,
            collapsedIconColor: Colors.white54,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: chapters,
                  itemBuilder: (context, gridIndex) {
                    int chapterNum = gridIndex + 1;
                    return InkWell(
                      onTap: () {
                        if (widget.isForCommentary) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommentaryScreen(book: bookName, chapter: chapterNum),
                            ),
                          );
                        } else if (widget.isForStrongs) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConcordanceScreen(book: bookName, chapter: chapterNum),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BibleReaderScreen(book: bookName, chapter: chapterNum),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Center(
                          child: Text(
                            chapterNum.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
