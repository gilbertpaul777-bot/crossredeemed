import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import 'notifications_settings_screen.dart';
import 'help_center_screen.dart';
import 'community_guidelines_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'report_problem_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildSectionHeader('Account'),
            _buildGlassCard(
              children: [
                _buildListTile(context, Icons.person_outline, 'Edit Profile', const EditProfileScreen()),
                _buildDivider(),
                _buildListTile(context, Icons.shield_outlined, 'Privacy & Data', const PrivacySettingsScreen()),
                _buildDivider(),
                _buildListTile(context, Icons.notifications_none, 'Notifications', const NotificationsSettingsScreen(), isLast: true),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Support & About'),
            _buildGlassCard(
              children: [
                _buildListTile(context, Icons.help_outline, 'Help Center', const HelpCenterScreen()),
                _buildDivider(),
                _buildListTile(context, Icons.gavel, 'Community Guidelines', const CommunityGuidelinesScreen()),
                _buildDivider(),
                _buildListTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', const PrivacyPolicyScreen()),
                _buildDivider(),
                _buildListTile(context, Icons.description_outlined, 'Terms of Service', const TermsOfServiceScreen()),
                _buildDivider(),
                _buildListTile(context, Icons.report_problem_outlined, 'Report a Problem', const ReportProblemScreen(), isLast: true),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Login'),
            _buildLogOutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.accentGold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: Colors.white.withAlpha(20)),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, Widget destination, {bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLast ? 14 : 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.black.withAlpha(50),
          child: InkWell(
            onTap: () => _showLogOutDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent.withAlpha(50)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withAlpha(10)),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Log out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to log out of your account?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close settings screen
              await Supabase.instance.client.auth.signOut();
            },
            child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
}
