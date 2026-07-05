import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'add_scripture_overlay_screen.dart';
import 'add_text_overlay_screen.dart';
import 'preview_post_screen.dart';
import '../../theme/app_theme.dart';

class EditVideoScreen extends StatefulWidget {
  final XFile videoFile;

  const EditVideoScreen({super.key, required this.videoFile});

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  
  double _trimStart = 0.0;
  double _trimEnd = 1.0;
  double _maxDuration = 1.0;

  String? _overlayText; // Could be scripture or custom text
  double _overlayX = 0;
  double _overlayY = 0;
  
  String _selectedFilter = 'none';
  bool _showFilters = false;

  final List<Map<String, dynamic>> _filters = [
    {'id': 'none', 'name': 'Normal', 'matrix': <double>[
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ]},
    {'id': 'grayscale', 'name': 'Grayscale', 'matrix': <double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]},
    {'id': 'sepia', 'name': 'Sepia', 'matrix': <double>[
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0,     0,     0,     1, 0,
    ]},
    {'id': 'high_contrast', 'name': 'Contrast', 'matrix': <double>[
      1.5, 0, 0, 0, -0.25 * 255,
      0, 1.5, 0, 0, -0.25 * 255,
      0, 0, 1.5, 0, -0.25 * 255,
      0, 0, 0, 1, 0,
    ]},
  ];

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player = Player();
    _controller = VideoController(_player);

    await _player.open(Media(widget.videoFile.path), play: false);
    
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.play();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _maxDuration = _player.state.duration.inMilliseconds.toDouble();
        if (_maxDuration == 0) _maxDuration = 1000.0;
        _trimStart = 0.0;
        _trimEnd = _maxDuration;
      });
    }

    _player.stream.position.listen((position) {
      if (!_isInitialized) return;
      final currentPos = position.inMilliseconds.toDouble();
      if (currentPos >= _trimEnd) {
        _player.seek(Duration(milliseconds: _trimStart.toInt()));
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  
  void _addScripture() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const AddScriptureOverlayScreen())
    );
    if (result != null && result is String) {
      setState(() {
        _overlayText = result;
        _overlayX = 0; // Reset position
        _overlayY = 0;
      });
    }
  }

  void _addText() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const AddTextOverlayScreen())
    );
    if (result != null && result is String) {
      setState(() {
        _overlayText = result;
        _overlayX = 0;
        _overlayY = 0;
      });
    }
  }

  void _next() {
    _player.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPostScreen(
          videoFile: widget.videoFile,
          trimStartMs: _trimStart,
          trimEndMs: _trimEnd,
          overlayText: _overlayText,
          overlayX: _overlayX,
          overlayY: _overlayY,
          filterId: _selectedFilter,
        ),
      ),
    ).then((_) {
      _player.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
      );
    }

    final activeMatrix = _filters.firstWhere((f) => f['id'] == _selectedFilter)['matrix'] as List<double>;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player Layer
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_showFilters) {
                  setState(() => _showFilters = false);
                  return;
                }
                _player.state.playing ? _player.pause() : _player.play();
              },
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(activeMatrix),
                child: Video(
                  controller: _controller,
                  controls: NoVideoControls,
                ),
              ),
            ),
          ),
          
          // Draggable Overlay Layer
          if (_overlayText != null)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 150 + _overlayX,
              top: MediaQuery.of(context).size.height / 2 - 50 + _overlayY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _overlayX += details.delta.dx;
                    _overlayY += details.delta.dy;
                  });
                },
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentGold, width: 2),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        _overlayText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Positioned(
                        top: -24,
                        right: -24,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: () {
                            setState(() {
                              _overlayText = null;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

          // Top Nav
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),

          // Right Sidebar
          if (!_showFilters)
            Positioned(
              top: 100,
              right: 20,
              child: Column(
                children: [
                  _buildSidebarButton(Icons.text_fields, 'Text', _addText),
                  const SizedBox(height: 20),
                  _buildSidebarButton(Icons.menu_book, 'Scripture', _addScripture),
                  const SizedBox(height: 20),
                  _buildSidebarButton(Icons.auto_awesome, 'Filters', () {
                    setState(() => _showFilters = true);
                  }),
                ],
              ),
            ),

          // Filters Bottom Sheet UI
          if (_showFilters)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                color: Colors.black87,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter['id'] == _selectedFilter;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter['id'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 80,
                        decoration: BoxDecoration(
                          border: isSelected ? Border.all(color: AppTheme.primaryPurple, width: 3) : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              filter['name'],
                              style: TextStyle(
                                color: isSelected ? AppTheme.primaryPurple : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Bottom Trimmer Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(178),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Trim Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: RangeValues(_trimStart, _trimEnd),
                    min: 0.0,
                    max: _maxDuration,
                    activeColor: AppTheme.primaryPurple,
                    inactiveColor: Colors.white30,
                    onChanged: (RangeValues values) {
                      setState(() {
                        if (values.end - values.start >= 1000) {
                          _trimStart = values.start;
                          _trimEnd = values.end;
                        }
                      });
                      _player.seek(Duration(milliseconds: _trimStart.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_trimStart / 1000).toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '${(_trimEnd / 1000).toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
