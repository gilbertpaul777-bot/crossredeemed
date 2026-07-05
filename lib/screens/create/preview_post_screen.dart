import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cross_file/cross_file.dart';
import '../../theme/app_theme.dart';


class PreviewPostScreen extends StatefulWidget {
  final XFile videoFile;
  final double trimStartMs;
  final double trimEndMs;
  final String? overlayText;
  final double? overlayX;
  final double? overlayY;
  final String? filterId;

  const PreviewPostScreen({
    super.key,
    required this.videoFile,
    required this.trimStartMs,
    required this.trimEndMs,
    this.overlayText,
    this.overlayX,
    this.overlayY,
    this.filterId,
  });

  @override
  State<PreviewPostScreen> createState() => _PreviewPostScreenState();
}

class _PreviewPostScreenState extends State<PreviewPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  String _status = '';
  
  bool _allowComments = true;
  String _privacyMode = 'Public';

  Future<void> _executeUpload(String finalStatus) async {
    setState(() {
      _isUploading = true;
      _status = finalStatus == 'draft' ? 'Saving to Drafts...' : 'Preparing upload...';
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

      // UPLOAD TO VIDEOS BUCKET
      await Supabase.instance.client.storage
          .from('videos')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
                contentType: 'video/$extension',
                upsert: true,
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('videos')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('posts').insert({
        'id': videoId,
        'user_id': user.id,
        'content': _captionController.text,
        'video_url': publicUrl, // Save the actual URL even for drafts
        'status': finalStatus, // 'draft' or 'ready'
        'created_at': DateTime.now().toIso8601String(),
        'likes_count': 0,
        'comments_count': 0,
        'metadata': {
          'filter_id': widget.filterId ?? 'none',
          'overlay_text': widget.overlayText,
          'overlay_x': widget.overlayX,
          'overlay_y': widget.overlayY,
          'trim_start_ms': widget.trimStartMs,
          'trim_end_ms': widget.trimEndMs,
        }
      });

      setState(() {
        _status = finalStatus == 'draft' ? 'Saved to Drafts!' : 'Upload complete!';
      });
      
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          // Navigate completely out to home/profile
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Upload failed: $e';
        // Hide overlay after 3 seconds so user can try again
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _isUploading = false);
          }
        });
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption Area (Glassmorphic)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withAlpha(20)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _captionController,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    maxLines: 5,
                                    minLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Describe your post, add hashtags, or mention creators',
                                      hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildHashtagChip('#faith'),
                                      const SizedBox(width: 8),
                                      _buildHashtagChip('#worship'),
                                      const SizedBox(width: 8),
                                      _buildHashtagChip('@mention'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Mock Thumbnail
                      Container(
                        width: 80,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1438232992991-995b7058bbb3'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Settings Options
                  _buildSettingOption(
                    icon: Icons.public,
                    title: 'Who can watch this video',
                    value: _privacyMode,
                    onTap: () {
                      setState(() {
                        _privacyMode = _privacyMode == 'Public' ? 'Friends' : 'Public';
                      });
                    },
                  ),
                  _buildSettingOption(
                    icon: Icons.comment,
                    title: 'Allow comments',
                    trailing: Switch(
                      value: _allowComments,
                      activeThumbColor: AppTheme.accentGold,
                      onChanged: (val) => setState(() => _allowComments = val),
                    ),
                  ),
                  _buildSettingOption(
                    icon: Icons.music_note,
                    title: 'Add Music',
                    value: 'None',
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _executeUpload('draft'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Drafts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _executeUpload('ready'),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.primaryPurple, Color(0xFF6A1B9A)]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(color: AppTheme.primaryPurple.withAlpha(80), blurRadius: 10, offset: const Offset(0, 4))
                              ]
                            ),
                            child: const Text('Post', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            // Full Screen Glassmorphic Upload Overlay
            if (_isUploading)
              Positioned.fill(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.black.withAlpha(150),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: AppTheme.accentGold,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _status,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: trailing ?? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildHashtagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
