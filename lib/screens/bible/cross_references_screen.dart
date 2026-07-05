import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/bible_service.dart';
import 'bible_reader_screen.dart';

class CrossReferencesScreen extends StatefulWidget {
  final String baseBook;
  final int baseChapter;
  final int baseVerse;

  const CrossReferencesScreen({
    super.key,
    this.baseBook = 'John',
    this.baseChapter = 3,
    this.baseVerse = 16,
  });

  @override
  State<CrossReferencesScreen> createState() => _CrossReferencesScreenState();
}

class _CrossReferencesScreenState extends State<CrossReferencesScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String _baseVerseText = '';
  List<Map<String, dynamic>> _references = [];
  
  // Split Screen State
  bool _isSplitScreen = false;
  Map<String, dynamic>? _selectedReference;
  
  // Animation controllers
  late AnimationController _webAnimController;

  @override
  void initState() {
    super.initState();
    _webAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _webAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load base verse text
    final text = await BibleService.getVerse(widget.baseBook, widget.baseChapter, widget.baseVerse);
    _baseVerseText = text ?? 'Verse not found';

    // Load cross references JSON
    final String baseRef = '${widget.baseBook} ${widget.baseChapter}:${widget.baseVerse}';
    try {
      final jsonStr = await rootBundle.loadString('assets/cross_references.json');
      final List<dynamic> data = jsonDecode(jsonStr);
      
      final refs = data.where((item) => item['base_verse'] == baseRef).toList();
      _references = List<Map<String, dynamic>>.from(refs);
      
      // Sort by votes
      _references.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
    } catch (e) {
      debugPrint('Error loading cross references: $e');
    }

    setState(() => _isLoading = false);
  }

  void _openSplitScreen(Map<String, dynamic> ref) {
    setState(() {
      _selectedReference = ref;
      _isSplitScreen = true;
    });
  }

  void _closeSplitScreen() {
    setState(() {
      _isSplitScreen = false;
      _selectedReference = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
      );
    }

    final String baseRef = '${widget.baseBook} ${widget.baseChapter}:${widget.baseVerse}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Top App Bar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Cross References', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                centerTitle: true,
              ),
              
              // 1. Visual Scripture Web
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _webAnimController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ScriptureWebPainter(
                        baseNode: baseRef,
                        nodes: _references,
                        animationValue: _webAnimController.value,
                      ),
                    );
                  },
                ),
              ),
              
              // 2. List of Cross References
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _references.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(baseRef, style: const TextStyle(color: AppTheme.accentGold, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_baseVerseText, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.link, color: Colors.white54, size: 20),
                                  const SizedBox(width: 8),
                                  Text('${_references.length} Connected Verses', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final ref = _references[index - 1];
                      return _ReferenceCard(
                        referenceData: ref,
                        onSplitScreen: () => _openSplitScreen(ref),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // 3. Split Screen Mode Overlay
          if (_isSplitScreen && _selectedReference != null)
            _buildSplitScreenOverlay(),
        ],
      ),
    );
  }

  Widget _buildSplitScreenOverlay() {
    final String refStr = _selectedReference!['reference'] as String;
    // Parse refStr e.g. "Romans 5:8" or "1 John 4:9"
    String targetBook = '';
    int targetChapter = 1;
    try {
      final parts = refStr.split(' ');
      final verseParts = parts.last.split(':');
      targetChapter = int.parse(verseParts[0]);
      targetBook = parts.sublist(0, parts.length - 1).join(' ');
    } catch (e) {
      targetBook = 'Romans';
    }

    return Positioned.fill(
      child: Column(
        children: [
          // Top Half (Base Verse)
          Expanded(
            flex: 1,
            child: Container(
              color: AppTheme.backgroundDark.withValues(alpha: 0.95),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${widget.baseBook} ${widget.baseChapter}:${widget.baseVerse}', 
                            style: const TextStyle(color: AppTheme.accentGold, fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white54),
                            onPressed: _closeSplitScreen,
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_baseVerseText, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Divider Drag Handle (Visual only for now)
          Container(
            height: 24,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.nebulaGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Bottom Half (Cross Reference Chapter)
          Expanded(
            flex: 2,
            child: Container(
              color: AppTheme.surfaceDark,
              // Reuse BibleReaderScreen but in a constrained box
              child: BibleReaderScreen(
                book: targetBook,
                chapter: targetChapter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceCard extends StatefulWidget {
  final Map<String, dynamic> referenceData;
  final VoidCallback onSplitScreen;

  const _ReferenceCard({required this.referenceData, required this.onSplitScreen});

  @override
  State<_ReferenceCard> createState() => _ReferenceCardState();
}

class _ReferenceCardState extends State<_ReferenceCard> {
  bool _isExpanded = false;
  String? _verseText;
  bool _isLoading = false;

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Prophecy Fulfilled': return Colors.purpleAccent;
      case 'Direct Quote': return Colors.orangeAccent;
      case 'Thematic': return Colors.lightBlueAccent;
      default: return Colors.white54;
    }
  }

  Future<void> _fetchVerseText() async {
    if (_verseText != null) return;
    
    setState(() => _isLoading = true);
    final refStr = widget.referenceData['reference'] as String;
    try {
      final parts = refStr.split(' ');
      final verseParts = parts.last.split(':');
      final verseNums = verseParts[1].split('-'); // handle ranges like "18-19"
      
      final targetChapter = int.parse(verseParts[0]);
      final targetVerse = int.parse(verseNums[0]);
      final targetBook = parts.sublist(0, parts.length - 1).join(' ');

      _verseText = await BibleService.getVerse(targetBook, targetChapter, targetVerse);
    } catch (e) {
      _verseText = "Error loading verse.";
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _fetchVerseText();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.referenceData['tag'] as String;
    final tagColor = _getTagColor(tag);
    
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.referenceData['reference'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.1),
                      border: Border.all(color: tagColor.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(tag, style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              _verseText ?? 'Could not load text.',
                              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.splitscreen, color: AppTheme.accentGold, size: 18),
                            label: const Text('Study in Split-Screen', style: TextStyle(color: AppTheme.accentGold)),
                            onPressed: widget.onSplitScreen,
                          ),
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScriptureWebPainter extends CustomPainter {
  final String baseNode;
  final List<Map<String, dynamic>> nodes;
  final double animationValue;

  ScriptureWebPainter({required this.baseNode, required this.nodes, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    final paintGlowLine = Paint()
      ..color = AppTheme.primaryPurple.withValues(alpha: 0.4)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Draw lines
    final radius = math.min(size.width, size.height) * 0.4;
    final int nodeCount = math.min(nodes.length, 8); // Max 8 nodes visually
    
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i * 2 * math.pi / nodeCount) + (animationValue * math.pi * 2);
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      final target = Offset(dx, dy);

      // Draw connection
      canvas.drawLine(center, target, paintGlowLine);
      canvas.drawLine(center, target, paintLine);
      
      // Draw sub-nodes
      canvas.drawCircle(target, 4, Paint()..color = Colors.white70);
      
      // Draw text for top 3
      if (i < 3) {
        final textPainter = TextPainter(
          text: TextSpan(text: nodes[i]['reference'], style: const TextStyle(color: Colors.white54, fontSize: 10)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(target.dx + 8, target.dy - 6));
      }
    }

    // Draw center node (Base Verse)
    canvas.drawCircle(center, 12, Paint()..color = AppTheme.accentGold.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(center, 6, Paint()..color = AppTheme.accentGold);
  }

  @override
  bool shouldRepaint(covariant ScriptureWebPainter oldDelegate) => true;
}
