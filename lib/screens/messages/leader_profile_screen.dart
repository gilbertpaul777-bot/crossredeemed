import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'sanctuary_chat_screen.dart';
import 'verified_church_screen.dart';

class LeaderProfileScreen extends StatelessWidget {
  final Map<String, dynamic> leaderData;

  const LeaderProfileScreen({super.key, required this.leaderData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Spiritual Leader', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(leaderData['avatar_url']),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset('assets/images/priest_pastor_verified_badge_v2.png', height: 40, width: 40),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Name & Status
              Text(
                leaderData['name'],
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: leaderData['status'] == 'Available Now' ? Colors.green.withAlpha(50) : Colors.orange.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: leaderData['status'] == 'Available Now' ? Colors.green : Colors.orange),
                ),
                child: Text(
                  leaderData['status'],
                  style: TextStyle(
                    color: leaderData['status'] == 'Available Now' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info Cards
              _buildInfoRow('Denomination', leaderData['denomination']),
              const Divider(color: Colors.white24),
              _buildInfoRow('Experience', leaderData['experience']),
              const Divider(color: Colors.white24),
              
              // Specialties
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Specialties', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: (leaderData['specialties'] as List<String>).map((spec) {
                  return Chip(
                    label: Text(spec, style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppTheme.primaryPurple.withAlpha(150),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 48),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SanctuaryChatScreen(leaderData: leaderData),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message for Guidance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerifiedChurchScreen(churchName: leaderData['church_name']),
                      ),
                    );
                  },
                  icon: const Icon(Icons.church_outlined),
                  label: Text('View ${leaderData['church_name']}', style: const TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.accentGold, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
