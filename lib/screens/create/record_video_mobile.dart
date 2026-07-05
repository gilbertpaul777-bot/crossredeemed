import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_video_screen.dart';
import 'audio_picker_sheet.dart';
import '../../theme/app_theme.dart';

class RecordVideoScreen extends StatefulWidget {
  const RecordVideoScreen({super.key});

  @override
  State<RecordVideoScreen> createState() => _RecordVideoScreenState();
}

class _RecordVideoScreenState extends State<RecordVideoScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  bool _isInitializing = true;
  bool _isFrontCamera = true;
  String _error = '';

  String? _selectedSoundTitle;
  int _currentFilterIndex = 0;

  final List<ColorFilter> _filters = [
    const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
    const ColorFilter.matrix([0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0]), // Grayscale
    const ColorFilter.matrix([0.393, 0.769, 0.189, 0, 0, 0.349, 0.686, 0.168, 0, 0, 0.272, 0.534, 0.131, 0, 0, 0, 0, 0, 1, 0]), // Sepia
    const ColorFilter.matrix([-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]), // Invert
  ];
  final List<String> _filterNames = ['None', 'Grayscale', 'Sepia', 'Invert'];

  int _timerSetting = 0; // 0 (off), 3, or 10 seconds
  int? _countdownValue;
  Timer? _countdownTimer;
  
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No cameras found';
          _isInitializing = false;
        });
        return;
      }
      
      // Use the front camera if available, else back camera
      final cameraDir = _isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back;
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == cameraDir,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true, 
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitializing = false);
    } on CameraException catch (e) {
      String errorMessage = 'Failed to initialize camera: ${e.code}';
      if (e.code == 'CameraAccessDenied' || e.code == 'CameraAccessDeniedWithoutPrompt') {
        errorMessage = 'Camera permissions denied. Please enable them in your device settings.';
      }
      setState(() {
        _error = errorMessage;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
        _isInitializing = false;
      });
    }
  }
  
  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitializing = true;
    });
    _initCamera();
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

  Future<void> _cycleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.torch;
        break;
      default:
        nextMode = FlashMode.off;
        break;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flash not supported: $e')));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      _initCamera();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_countdownValue != null) {
      // Cancel active countdown
      _countdownTimer?.cancel();
      setState(() => _countdownValue = null);
      return;
    }

    if (_isRecording) {
      // Stop recording
      try {
        final XFile file = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EditVideoScreen(videoFile: file),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error stopping record: $e')));
      }
    } else {
      // Start recording (with optional timer)
      if (_timerSetting > 0) {
        setState(() => _countdownValue = _timerSetting);
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (_countdownValue == null) {
            timer.cancel(); // Cancelled by user
            return;
          }
          
          if (_countdownValue! > 1) {
            setState(() => _countdownValue = _countdownValue! - 1);
          } else {
            timer.cancel();
            setState(() => _countdownValue = null);
            await _startActualRecording();
          }
        });
      } else {
        await _startActualRecording();
      }
    }
  }

  Future<void> _startActualRecording() async {
    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting record: $e')));
    }
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: ColorFiltered(
                  colorFilter: _filters[_currentFilterIndex],
                  child: CameraPreview(_controller!),
                ),
              ),
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
                _buildToolbarButton(Icons.flip_camera_android, 'Flip', onTap: _flipCamera),
                const SizedBox(height: 20),
                _buildToolbarButton(Icons.speed, 'Speed', onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speed controls coming soon')));
                }),
                const SizedBox(height: 20),
                _buildToolbarButton(Icons.filter_vintage, 'Filters', onTap: () {
                  setState(() {
                    _currentFilterIndex = (_currentFilterIndex + 1) % _filters.length;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Filter: ${_filterNames[_currentFilterIndex]}'),
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
                const SizedBox(height: 20),
                _buildToolbarButton(
                  _flashMode == FlashMode.off ? Icons.flash_off : (_flashMode == FlashMode.auto ? Icons.flash_auto : Icons.flash_on),
                  _flashMode == FlashMode.off ? 'Flash Off' : (_flashMode == FlashMode.auto ? 'Auto' : 'Torch'),
                  onTap: _cycleFlash
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
                        final picker = ImagePicker();
                        final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                        if (!context.mounted) return;
                        if (video != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => EditVideoScreen(videoFile: video),
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
