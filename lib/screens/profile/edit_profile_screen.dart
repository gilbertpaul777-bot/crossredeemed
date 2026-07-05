import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../theme/app_theme.dart';
import 'package:cross_redeemed/widgets/ichthys_icon.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _isLoading = false;
  String? _avatarUrl;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      _usernameCtrl.text = meta?['username'] ?? user.email?.split('@')[0] ?? '';
      _bioCtrl.text = meta?['bio'] ?? '';
      _avatarUrl = meta?['avatar_url'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      String? newAvatarUrl = _avatarUrl;

      // 1. Upload new image if selected
      if (_selectedImage != null && _imageBytes != null) {
        final fileExt = _selectedImage!.name.split('.').last.toLowerCase();
        final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        await _supabase.storage.from('avatars').uploadBinary(
          fileName, 
          _imageBytes!,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
          ),
        );
        
        // Get the public URL
        newAvatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // 2. Update user metadata
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'username': _usernameCtrl.text.trim(),
            'bio': _bioCtrl.text.trim(),
            'avatar_url': newAvatarUrl,
          },
        ),
      );

      // 3. Sync to public profiles table
      await _supabase.from('profiles').update({
        'username': _usernameCtrl.text.trim(),
        'avatar_url': newAvatarUrl,
      }).eq('id', user.id);

      navigator.pop();
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      debugPrint('Error updating profile: $e');
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
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
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar section
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.surfaceDark,
                          backgroundImage: _imageBytes != null 
                            ? MemoryImage(_imageBytes!) 
                            : (_avatarUrl != null ? NetworkImage(_avatarUrl!) as ImageProvider : null),
                          child: (_imageBytes == null && _avatarUrl == null)
                            ? const IchthysIcon( size: 50, color: Colors.white54)
                            : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Change Photo', style: TextStyle(color: Colors.white54)),
                  
                  const SizedBox(height: 32),
                  
                  // Username Field
                  TextField(
                    controller: _usernameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.alternate_email, color: Colors.white54),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bio Field
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      alignLabelWithHint: true,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
