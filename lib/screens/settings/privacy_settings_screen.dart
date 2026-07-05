import 'package:flutter/material.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:cross_redeemed/services/data_privacy_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isExporting = false;
  bool _isDeleting = false;

  Future<void> _handleDataExport() async {
    setState(() => _isExporting = true);
    try {
      await DataPrivacyService.requestDataExport();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your data export is being processed. You will receive an email shortly.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleAccountDeletion() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Delete Account?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This action is permanent and cannot be undone. All your posts, messages, and profile data will be permanently erased in accordance with GDPR/CCPA.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await DataPrivacyService.deleteAccount();
      if (mounted) {
        // Pop until first route or push replacement to login screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.nebulaGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Privacy & Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data Portability',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Under GDPR and CCPA, you have the right to request a copy of all personal data we have collected about you.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isExporting ? null : _handleDataExport,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.accentGold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isExporting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppTheme.accentGold, strokeWidth: 2))
                    : const Icon(Icons.download, color: AppTheme.accentGold),
                  label: const Text('Download My Data', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Danger Zone',
                style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Once you delete your account, there is no going back. Please be certain.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDeleting ? null : _handleAccountDeletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withAlpha(50),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  icon: _isDeleting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2))
                    : const Icon(Icons.delete_forever),
                  label: const Text('Permanently Delete Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
