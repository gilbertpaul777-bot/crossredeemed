import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cross_file/cross_file.dart';
import '../../theme/app_theme.dart';

class UploadVideoScreen extends StatefulWidget {
  final XFile videoFile;
  const UploadVideoScreen({super.key, required this.videoFile});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  bool _isUploading = false;
  String _status = 'Ready to upload';

  Future<void> _uploadVideo() async {
    setState(() {
      _isUploading = true;
      _status = 'Preparing upload...';
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final videoId = const Uuid().v4();

      setState(() {
        _status = 'Uploading Video...';
      });

      final bytes = await widget.videoFile.readAsBytes();
      final extension = widget.videoFile.name.split('.').last;
      final fileName = '$videoId.$extension';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
                contentType: 'video/$extension',
                upsert: true,
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('posts').insert({
        'id': videoId,
        'user_id': user.id,
        'content': 'My New Video!',
        'video_url': publicUrl,
        'status': 'ready',
      });

      setState(() {
        _status = 'Upload complete!';
      });
      
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }

    } catch (e) {
      setState(() {
        _status = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Post Video'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_file, size: 80, color: Colors.white70),
              const SizedBox(height: 20),
              Text(
                'Video selected:\n${widget.videoFile.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 40),
              if (_isUploading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
              ],
              Text(
                _status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _status.contains('failed') ? Colors.red : Colors.white, 
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              if (!_isUploading)
                ElevatedButton(
                  onPressed: _uploadVideo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: const Color(0xFF7B1FA2), // Purple
                  ),
                  child: const Text('Upload & Post', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
