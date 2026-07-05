import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/bible_service.dart';
import '../../providers/bible_settings_provider.dart';
import 'bible_settings_modal.dart';
import 'chapter_view_screen.dart';
import 'commentary_screen.dart';
import 'concordance_screen.dart';

class BibleReaderScreen extends StatefulWidget {
  final String book;
  final int chapter;

  const BibleReaderScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  List<dynamic> _verses = [];
  Map<int, String> _highlights = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChapter();
  }

  Future<void> _fetchChapter() async {
    try {
      final response = await BibleService.getChapter(widget.book, widget.chapter);
      
      Map<int, String> fetchedHighlights = {};
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final hlResponse = await Supabase.instance.client
            .from('bible_highlights')
            .select()
            .eq('book', widget.book)
            .eq('chapter', widget.chapter)
            .eq('user_id', user.id);
        for (var row in hlResponse) {
          fetchedHighlights[row['verse'] as int] = row['color_hex'] as String;
        }
      }

      setState(() {
        _verses = response;
        _highlights = fetchedHighlights;
        _isLoading = false;
      });
      _logHistory();
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching chapter: $e');
    }
  }

  Future<void> _logHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client.from('bible_history').upsert({
        'user_id': user.id,
        'book': widget.book,
        'chapter': widget.chapter,
        'last_read_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, book, chapter');
    } catch (e) {
      debugPrint('History err: $e');
    }
  }

  void _addNoteDialog(dynamic verse) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text('Add Note for ${widget.book} ${widget.chapter}:${verse['verse']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your thoughts...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              final user = Supabase.instance.client.auth.currentUser;
              if (user != null && ctrl.text.trim().isNotEmpty) {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await Supabase.instance.client.from('bible_notes').insert({
                  'user_id': user.id,
                  'book': widget.book,
                  'chapter': widget.chapter,
                  'verse': verse['verse'],
                  'verse_text': verse['text'],
                  'note_text': ctrl.text.trim(),
                });
                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('Note saved!')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text('Save Note', style: TextStyle(color: Colors.white)),
          )
        ],
      );
    });
  }

  Future<void> _applyHighlight(dynamic verse, String hexCode) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to highlight verses.')));
      return;
    }
    
    Navigator.pop(context); // close sheet
    final verseNum = verse['verse'] as int;
    
    setState(() {
      _highlights[verseNum] = hexCode;
    });

    try {
      await Supabase.instance.client.from('bible_highlights').upsert({
        'user_id': user.id,
        'book': widget.book,
        'chapter': widget.chapter,
        'verse': verseNum,
        'color_hex': hexCode,
      }, onConflict: 'user_id, book, chapter, verse');
    } catch (e) {
      debugPrint('Error highlighting: $e');
    }
  }

  Future<void> _removeHighlight(dynamic verse) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    Navigator.pop(context);
    final verseNum = verse['verse'] as int;
    
    setState(() {
      _highlights.remove(verseNum);
    });

    try {
      await Supabase.instance.client
          .from('bible_highlights')
          .delete()
          .eq('user_id', user.id)
          .eq('book', widget.book)
          .eq('chapter', widget.chapter)
          .eq('verse', verseNum);
    } catch (e) {
      debugPrint('Error removing highlight: $e');
    }
  }

  Widget _buildHighlightRow(dynamic verse) {
    final colors = [
      {'hex': '#FFF59D'}, // Yellow
      {'hex': '#A5D6A7'}, // Green
      {'hex': '#81D4FA'}, // Blue
      {'hex': '#F48FB1'}, // Pink
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...colors.map((c) => GestureDetector(
            onTap: () => _applyHighlight(verse, c['hex']!),
            child: Container(
              width: 40, height: 40, 
              decoration: BoxDecoration(color: Color(int.parse(c['hex']!.replaceFirst('#', '0xFF'))), shape: BoxShape.circle)
            ),
          )),
          GestureDetector(
            onTap: () => _removeHighlight(verse),
            child: Container(
              width: 40, height: 40, 
              decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.white54), shape: BoxShape.circle), 
              child: const Icon(Icons.format_color_reset, color: Colors.white)
            ),
          )
        ],
      ),
    );
  }

  void _showVerseOptions(dynamic verse) {
    String cleanText = verse['text'].toString().replaceAll(RegExp(r'<[^>]*>'), '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(5))),
              const SizedBox(height: 20),
              Text('${widget.book} ${widget.chapter}:${verse['verse']}', style: const TextStyle(color: AppTheme.accentGold, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('"$cleanText"', style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              _buildHighlightRow(verse),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white),
                title: const Text('Copy', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: '${widget.book} ${widget.chapter}:${verse['verse']}\n"$cleanText"'));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verse copied to clipboard!')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Colors.white),
                title: const Text('Bookmark', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user != null) {
                    await Supabase.instance.client.from('bible_bookmarks').insert({
                      'user_id': user.id,
                      'book': widget.book,
                      'chapter': widget.chapter,
                      'verse': verse['verse'],
                      'text': verse['text'],
                    });
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark saved!')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.white),
                title: const Text('Add Note', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _addNoteDialog(verse);
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate, color: Colors.white),
                title: const Text("Strong's Concordance", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConcordanceScreen(book: widget.book, chapter: widget.chapter),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book, color: Colors.white),
                title: const Text("Matthew Henry Commentary", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentaryScreen(book: widget.book, chapter: widget.chapter),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // ignore: deprecated_member_use
                  Share.share('${widget.book} ${widget.chapter}:${verse['verse']} - "$cleanText"');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<BibleSettingsProvider>();
    
    // Determine theme colors
    Color bgColor;
    Color textColor;
    Color verseNumberColor;
    
    switch (settings.themeMode) {
      case 'light':
        bgColor = Colors.white;
        textColor = Colors.black87;
        verseNumberColor = Colors.grey[600]!;
        break;
      case 'sepia':
        bgColor = const Color(0xFFF4ECD8);
        textColor = const Color(0xFF5B4636);
        verseNumberColor = const Color(0xFF8B7355);
        break;
      case 'cream':
        bgColor = const Color(0xFFFDFBF7);
        textColor = const Color(0xFF333333);
        verseNumberColor = Colors.grey[500]!;
        break;
      case 'dark':
      default:
        bgColor = AppTheme.backgroundDark;
        textColor = Colors.white;
        verseNumberColor = AppTheme.accentGold;
        break;
    }

    debugPrint('Rebuilding BibleReaderScreen with fontSize: ${settings.fontSize} and theme: ${settings.themeMode}');

    final textStyle = settings.fontFamily == 'Ancient'
        ? GoogleFonts.unifrakturMaguntia(color: textColor, fontSize: settings.fontSize, height: 1.6)
        : settings.fontFamily == 'Classic'
            ? GoogleFonts.ebGaramond(color: textColor, fontSize: settings.fontSize, height: 1.6)
            : GoogleFonts.roboto(color: textColor, fontSize: settings.fontSize, height: 1.6);

    final isGospel = ['Matthew', 'Mark', 'Luke', 'John', 'Revelation'].contains(widget.book);

    Widget buildVerses() {
      if (settings.isParagraphMode) {
        // --- PARAGRAPH MODE ---
        List<TextSpan> allSpans = [];

        for (int index = 0; index < _verses.length; index++) {
          final verse = _verses[index];
          final textStr = verse['text'] as String;
          final isFirstVerse = index == 0;
          final verseNum = verse['verse'] as int;
          
          final highlightHex = _highlights[verseNum];
          Color? highlightColor;
          if (highlightHex != null) {
            highlightColor = Color(int.parse(highlightHex.replaceFirst('#', '0xFF'))).withValues(alpha: 0.4);
          }

          // Verse Number
          if (settings.showVerseNumbers) {
            allSpans.add(TextSpan(
              text: index == 0 ? '${verse['verse']}  ' : '  ${verse['verse']} ',
              style: GoogleFonts.roboto(
                color: verseNumberColor,
                fontWeight: FontWeight.bold,
                fontSize: settings.fontSize * 0.75,
                backgroundColor: highlightColor,
              ),
            ));
          }

          // Gesture for tapping this verse
          final recognizer = TapGestureRecognizer()..onTap = () => _showVerseOptions(verse);

          // Add Red Letter and Drop Cap parsing
          if (isFirstVerse && textStr.isNotEmpty) {
            final firstLetter = textStr.substring(0, 1);
            final restOfText = textStr.substring(1);

            allSpans.add(TextSpan(
              text: firstLetter,
              style: textStyle.copyWith(
                fontSize: settings.fontSize * 2.5, 
                height: 1.0, 
                fontWeight: FontWeight.bold,
                backgroundColor: highlightColor,
              ),
              recognizer: recognizer,
            ));
            _appendVerseSpans(allSpans, restOfText, textStyle, isGospel, settings.isRedLetter, recognizer, highlightColor);
          } else {
            _appendVerseSpans(allSpans, textStr, textStyle, isGospel, settings.isRedLetter, recognizer, highlightColor);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(children: allSpans, style: textStyle),
          ),
        );
      } else {
        // --- VERSE-BY-VERSE MODE (Classic List) ---
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _verses.length,
          itemBuilder: (context, index) {
            final verse = _verses[index];
            final textStr = verse['text'] as String;
            final verseNum = verse['verse'] as int;

            final highlightHex = _highlights[verseNum];
            Color? highlightColor;
            if (highlightHex != null) {
              highlightColor = Color(int.parse(highlightHex.replaceFirst('#', '0xFF'))).withValues(alpha: 0.4);
            }

            List<TextSpan> verseSpans = [];
            _appendVerseSpans(verseSpans, textStr, textStyle, isGospel, settings.isRedLetter, null, highlightColor);

            return InkWell(
              onTap: () => _showVerseOptions(verse),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RichText(
                  text: TextSpan(
                    style: textStyle,
                    children: [
                      if (settings.showVerseNumbers)
                        TextSpan(
                          text: '${verse['verse']}  ',
                          style: GoogleFonts.roboto(
                            color: verseNumberColor,
                            fontWeight: FontWeight.bold,
                            fontSize: settings.fontSize * 0.75,
                            backgroundColor: highlightColor,
                          ),
                        ),
                      ...verseSpans,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: textColor),
          title: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChapterViewScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${widget.book} ${widget.chapter}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  Icon(Icons.arrow_drop_down, color: verseNumberColor),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_book, color: AppTheme.accentGold),
              tooltip: 'Open Commentary',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentaryScreen(
                      book: widget.book,
                      chapter: widget.chapter,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.text_format, color: textColor),
              onPressed: () {
                BibleSettingsModal.show(context);
              },
            )
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
                : _verses.isEmpty
                    ? const Center(
                        child: Text('Chapter not found.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      )
                    : buildVerses(),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white70),
                  label: const Text('Previous', style: TextStyle(color: Colors.white70)),
                  onPressed: () async {
                    final prev = await BibleService.getPreviousChapter(widget.book, widget.chapter);
                    if (!context.mounted) return;
                    if (prev != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => BibleReaderScreen(book: prev['book'], chapter: prev['chapter'])
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are at the beginning of the Bible.')));
                    }
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final next = await BibleService.getNextChapter(widget.book, widget.chapter);
                    if (!context.mounted) return;
                    if (next != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => BibleReaderScreen(book: next['book'], chapter: next['chapter'])
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are at the end of the Bible.')));
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Next', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _appendVerseSpans(
    List<TextSpan> spans,
    String text,
    TextStyle style,
    bool isGospel,
    bool isRedLetter,
    TapGestureRecognizer? recognizer,
    Color? highlightColor,
  ) {
    final effectiveStyle = highlightColor != null ? style.copyWith(backgroundColor: highlightColor) : style;

    if (isRedLetter && text.contains('<r>')) {
      final parts = text.split(RegExp(r'<r>|</r>'));
      for (int i = 0; i < parts.length; i++) {
        if (i % 2 != 0) {
          spans.add(TextSpan(
            text: parts[i],
            style: effectiveStyle.copyWith(color: Colors.red[800]),
            recognizer: recognizer,
          ));
        } else if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: effectiveStyle,
            recognizer: recognizer,
          ));
        }
      }
    } else {
      spans.add(TextSpan(
        text: text.replaceAll('<r>', '').replaceAll('</r>', ''),
        style: effectiveStyle,
        recognizer: recognizer,
      ));
    }
  }
}

