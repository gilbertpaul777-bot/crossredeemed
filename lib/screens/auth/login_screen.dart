import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:cross_redeemed/screens/auth/sign_up_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(); // wrapper handles routing
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

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController();
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withAlpha(150),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_reset, color: AppTheme.accentGold, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Reset Password',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your email address and we will send you a password reset link.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: resetEmailCtrl,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isResetting ? null : () async {
                                if (resetEmailCtrl.text.trim().isEmpty) return;
                                
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                
                                setDialogState(() => isResetting = true);
                                try {
                                  await _supabase.auth.resetPasswordForEmail(resetEmailCtrl.text.trim());
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Password reset link sent! Please check your email.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                                } finally {
                                  if (mounted) setDialogState(() => isResetting = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: isResetting 
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Send Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
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
              // Logo
              Container(
                width: 120,
                height: 120,
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
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildTextField(
                controller: _emailCtrl, 
                hint: 'Email or Username', 
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _passwordCtrl, 
                hint: 'Password', 
                icon: Icons.lock_outline,
                obscureText: true
              ),
              const SizedBox(height: 8),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _isLoading ? null : _login,
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
                          'LOG IN',
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
                  const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: const Text('Sign Up', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
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
