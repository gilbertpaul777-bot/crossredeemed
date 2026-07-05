import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:cross_redeemed/screens/auth/login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        data: {
          'username': _usernameCtrl.text.trim(),
          'display_name': _usernameCtrl.text.trim(),
        }
      );

      final user = res.user;
      if (user != null) {
        if (mounted) {
          Navigator.of(context).pop(); // Go back to welcome
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryPurple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withAlpha(128),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildTextField(
                controller: _usernameCtrl, 
                hint: 'Username',
                icon: Icons.person_outline
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _emailCtrl, 
                hint: 'Email', 
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _passwordCtrl, 
                hint: 'Password', 
                icon: Icons.lock_outline,
                obscureText: true
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _confirmPasswordCtrl, 
                hint: 'Confirm Password', 
                icon: Icons.lock_outline,
                obscureText: true
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _isLoading ? null : _signUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryPurple, Color(0xFF6A1B9A)]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          'SIGN UP',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white30)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.white54)),
                  ),
                  Expanded(child: Divider(color: Colors.white30)),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSocialLoginButton(const FaIcon(FontAwesomeIcons.google, color: Colors.white, size: 24), 'Continue with Google', _signInWithGoogle),
              const SizedBox(height: 16),
              _buildSocialLoginButton(const FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 24), 'Continue with Apple', _signInWithApple),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: const Text('Login', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: Icon(icon, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(Widget iconWidget, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
