import 'package:flutter/material.dart';
import '../../services/commentary_service.dart';
import '../../theme/app_theme.dart';

class CommentaryScreen extends StatefulWidget {
  final String book;
  final int chapter;

  const CommentaryScreen({
    super.key,
    this.book = 'Genesis',
    this.chapter = 1,
  });

  @override
  State<CommentaryScreen> createState() => _CommentaryScreenState();
}

class _CommentaryScreenState extends State<CommentaryScreen> {
  Map<String, String> _commentary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await CommentaryService().loadCommentary(widget.book);
    setState(() {
      _commentary = CommentaryService().getCommentaryForChapter(widget.book, widget.chapter);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.book} ${widget.chapter} - Commentary', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.nebulaGradient,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SafeArea(
              child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
              : _commentary.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text('Commentary not available for this chapter.', 
                            style: TextStyle(color: Colors.white54, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _commentary.length,
                      itemBuilder: (context, index) {
                        String verseNum = _commentary.keys.elementAt(index);
                        String text = _commentary[verseNum] ?? '';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Verse $verseNum',
                                  style: const TextStyle(
                                    color: AppTheme.accentGold, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.6,
                                  fontFamily: 'EB Garamond', // Classic look
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
