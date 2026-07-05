// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_video_screen.dart';
import 'audio_picker_sheet.dart';
import '../../theme/app_theme.dart';

class RecordVideoScreen extends StatefulWidget {
  const RecordVideoScreen({super.key});

  @override
  State<RecordVideoScreen> createState() => _RecordVideoScreenState();
}

class _RecordVideoScreenState extends State<RecordVideoScreen> {
  html.VideoElement? _webVideoElement;
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  List<html.Blob> _chunks = [];
  
  bool _isRecording = false;
  bool _isInitializing = true;
  String _error = '';
  final String _viewType = 'web-camera-preview-${DateTime.now().millisecondsSinceEpoch}';

  bool _isFrontCamera = true;
  String? _selectedSoundTitle;
  int _currentFilterIndex = 0;
  
  final List<String> _filters = [
    'none',
    'grayscale(100%)',
    'sepia(100%)',
    'invert(100%)',
    'saturate(200%)',
    'hue-rotate(90deg)',
    'blur(2px)',
  ];

  int _timerSetting = 0; // 0 (off), 3, or 10 seconds
  int? _countdownValue;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initWebCamera();
  }

  Future<void> _initWebCamera() async {
    try {
      if (_webVideoElement == null) {
        _webVideoElement = html.VideoElement()
          ..autoplay = true
          ..muted = true
          ..style.objectFit = 'cover'
          ..style.width = '100%'
          ..style.height = '100%';

        ui_web.platformViewRegistry.registerViewFactory(
          _viewType,
          (int viewId) => _webVideoElement!,
        );
      }

      _mediaStream?.getTracks().forEach((track) => track.stop());

      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': _isFrontCamera ? 'user' : 'environment'}, 
        'audio': true
      });
      _webVideoElement!.srcObject = _mediaStream;
      
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize WebRTC camera: $e';
        _isInitializing = false;
      });
    }
  }

  void _cycleTimer() {
    setState(() {
      if (_timerSetting == 0) {
        _timerSetting = 3;
      } else if (_timerSetting == 3) {
        _timerSetting = 10;
      } else {
        _timerSetting = 0;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_timerSetting == 0 ? 'Timer Off' : 'Timer set to $_timerSetting seconds'),
      duration: const Duration(seconds: 1),
    ));
  }

  void _toggleRecording() async {
    if (_mediaStream == null) return;

    if (_countdownValue != null) {
      // Cancel active countdown
      _countdownTimer?.cancel();
      setState(() => _countdownValue = null);
      return;
    }

    if (_isRecording) {
      // Stop recording
      _mediaRecorder?.stop();
      setState(() => _isRecording = false);
    } else {
      // Start recording
      _chunks = [];
      String mimeType = 'video/webm;codecs=vp8,opus';
      if (!html.MediaRecorder.isTypeSupported(mimeType)) {
        mimeType = 'video/mp4'; // fallback for Safari
      }
      
      _mediaRecorder = html.MediaRecorder(_mediaStream!, {'mimeType': mimeType});
      
      _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
        final html.Blob blob = (event as dynamic).data;
        if (blob.size > 0) {
          _chunks.add(blob);
        }
      });

      _mediaRecorder!.addEventListener('stop', (html.Event event) async {
        final blob = html.Blob(_chunks, mimeType);
        
        // Convert Blob to bytes for XFile
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoadEnd.first;
        final bytes = reader.result as Uint8List;
        
        final xfile = XFile.fromData(
          bytes,
          mimeType: mimeType,
          name: 'web_recording_${DateTime.now().millisecondsSinceEpoch}.webm',
        );

        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EditVideoScreen(videoFile: xfile),
        ));
      });

      // Handle Timer Countdown
      if (_timerSetting > 0) {
        setState(() => _countdownValue = _timerSetting);
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_countdownValue == null) {
            timer.cancel(); // Cancelled by user
            return;
          }
          
          if (_countdownValue! > 1) {
            setState(() => _countdownValue = _countdownValue! - 1);
          } else {
            timer.cancel();
            setState(() => _countdownValue = null);
            _mediaRecorder!.start();
            setState(() => _isRecording = true);
          }
        });
      } else {
        _mediaRecorder!.start();
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _webVideoElement?.removeAttribute('src');
    _webVideoElement?.load();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.nebulaGradient,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Camera Unavailable',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We couldn\'t access your camera. This usually happens on web browsers without permissions or missing hardware.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                      if (!context.mounted) return;
                      if (video != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EditVideoScreen(videoFile: video),
                        ));
                      }
                    },
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text('Upload from Gallery', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        )
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            color: Colors.black,
            child: Stack(
        children: [
          Positioned.fill(
            child: HtmlElementView(viewType: _viewType),
          ),
          
          // Countdown Overlay
          if (_countdownValue != null)
            Positioned.fill(
              child: Center(
                child: Text(
                  _countdownValue.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                  ),
                ),
              ),
            ),
          
          // Top Bar: Add Sound
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => AudioPickerSheet(
                        onSelectSound: (title, artist) {
                          setState(() {
                            _selectedSoundTitle = title;
                          });
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _selectedSoundTitle ?? 'Add Sound', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48), // Balance for the close button
              ],
            ),
          ),
          
          // Right Sidebar Toolbar
          Positioned(
            top: 100,
            right: 16,
            child: Column(
              children: [
                _buildToolbarButton(Icons.flip_camera_ios, 'Flip', onTap: () {
                  setState(() {
                    _isFrontCamera = !_isFrontCamera;
                  });
                  _initWebCamera();
                }),
                const SizedBox(height: 20),
                _buildToolbarButton(Icons.speed, 'Speed', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speed controls coming soon')));
                }),
                const SizedBox(height: 20),
                _buildToolbarButton(Icons.filter_vintage, 'Filters', onTap: () {
                  setState(() {
                    _currentFilterIndex = (_currentFilterIndex + 1) % _filters.length;
                    _webVideoElement?.style.filter = _filters[_currentFilterIndex];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Filter: ${_filters[_currentFilterIndex]}'),
                    duration: const Duration(seconds: 1),
                  ));
                }),
                const SizedBox(height: 20),
                _buildToolbarButton(Icons.face_retouching_natural, 'Beautify', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Beautify coming soon')));
                }),
                const SizedBox(height: 20),
                _buildToolbarButton(
                  _timerSetting == 0 ? Icons.timer_off : (_timerSetting == 3 ? Icons.timer_3 : Icons.timer_10), 
                  _timerSetting == 0 ? 'Timer' : '${_timerSetting}s', 
                  onTap: _cycleTimer
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Duration / Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Text', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    const Text('15s', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    const Text('60s', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    const Text('3m', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Effects
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Effects coming soon')));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 4),
                          const Text('Effects', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    
                    // Record Button
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _isRecording ? Colors.redAccent : const Color(0x66FFFFFF), width: 6),
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: _isRecording ? 30 : 65,
                            width: _isRecording ? 30 : 65,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Gallery Picker (Upload)
                    GestureDetector(
                      onTap: () async {
                        try {
                          final picker = ImagePicker();
                          final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                          if (!context.mounted) return;
                          if (video != null) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => EditVideoScreen(videoFile: video),
                            ));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Upload failed: $e'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.photo, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildToolbarButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
