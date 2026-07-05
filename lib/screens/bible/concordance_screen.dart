import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/strongs_service.dart';
import '../../services/bible_service.dart';

class ConcordanceScreen extends StatefulWidget {
  final String book;
  final int chapter;

  const ConcordanceScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  State<ConcordanceScreen> createState() => _ConcordanceScreenState();
}

class _ConcordanceScreenState extends State<ConcordanceScreen> {
  List<Map<String, dynamic>> _verses = [];
  List<Map<String, dynamic>> _kjvVerses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verses = await StrongsService.getInterlinearChapter(widget.book, widget.chapter);
      final kjvVerses = await BibleService.getChapter(widget.book, widget.chapter);
      if (mounted) {
        setState(() {
          _verses = verses;
          _kjvVerses = kjvVerses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showDefinition(BuildContext context, String strongsNumber, String englishWord) async {
    // Show a loading dialog first, then populate it
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: StrongsService.getDefinition(strongsNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "Definition not found.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final def = data['d'] ?? '';
            final pron = data['p'] ?? '';
            final strongs = strongsNumber.toUpperCase();

            return Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "\"$englishWord\"",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryPurple),
                          ),
                          child: Text(
                            strongs,
                            style: const TextStyle(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (pron.isNotEmpty) ...[
                      Text(
                        "Pronunciation: $pron",
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      "Definition",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      def,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
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
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.book} ${widget.chapter}', 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text("Strong's Concordance", 
              style: TextStyle(fontSize: 12, color: AppTheme.accentGold)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
              : _error != null
                  ? Center(child: Text("Error: $_error", style: const TextStyle(color: Colors.red)))
                  : _verses.isEmpty
                      ? const Center(child: Text("No concordance data found for this chapter.", style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _verses.length,
                          itemBuilder: (context, index) {
                        final v = _verses[index];
                        final vNum = v['verse'];
                        final words = v['data'] as List<dynamic>;

                        // Find corresponding standard KJV verse for red letter logic
                        String kjvVerseText = "";
                        if (index < _kjvVerses.length) {
                          kjvVerseText = _kjvVerses[index]['text'] ?? "";
                        }
                        bool verseHasRed = kjvVerseText.contains('<r>');
                        
                        // Extract just the red phrases to do simple matching
                        List<String> redPhrases = [];
                        if (verseHasRed) {
                          final regex = RegExp(r'<r>(.*?)</r>');
                          final matches = regex.allMatches(kjvVerseText);
                          for (var m in matches) {
                            redPhrases.add(m.group(1)!.toLowerCase());
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.8,
                              ),
                              children: [
                                TextSpan(
                                  text: '$vNum ',
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                ...words.map((wordData) {
                                  // Data structure:
                                  // {
                                  //   "t": "in the beginning|רֵאשִׁית|re'shiyth",
                                  //   "s": "h7225"
                                  // }
                                  final t = wordData['t'] as String? ?? "";
                                  final s = wordData['s'] as String? ?? "";
                                  
                                  // the text might be english|hebrew|translit
                                  final parts = t.split('|');
                                  final englishPart = parts.isNotEmpty ? parts[0] : t;

                                  // Check if word should be red
                                  bool isRed = false;
                                  if (verseHasRed) {
                                    String cleanEnglish = englishPart.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
                                    for (String redPhrase in redPhrases) {
                                      if (redPhrase.contains(cleanEnglish)) {
                                        isRed = true;
                                        break;
                                      }
                                    }
                                  }

                                  if (s.isEmpty) {
                                    return TextSpan(
                                      text: "$englishPart ",
                                      style: TextStyle(color: isRed ? Colors.red[800] : Colors.white)
                                    );
                                  }

                                  return WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: InkWell(
                                        onTap: () => _showDefinition(context, s, englishPart),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.5)),
                                          ),
                                          child: Text(
                                            englishPart,
                                            style: TextStyle(
                                              color: isRed ? Colors.red[200] : Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
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
