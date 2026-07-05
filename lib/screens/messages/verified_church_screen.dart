import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VerifiedChurchScreen extends StatelessWidget {
  final String churchName;
  final String denomination;
  final Map<String, dynamic>? churchData;

  const VerifiedChurchScreen({
    super.key, 
    required this.churchName,
    this.denomination = 'Non-Denominational',
    this.churchData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nebulaGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Organization Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Church Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.church, color: AppTheme.accentGold, size: 64),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          churchName,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 8),
                        Image.asset('assets/images/church_verified_badge.png', height: 32, width: 32),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Denomination Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withAlpha(80),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryPurple),
                      ),
                      child: Text(
                        denomination,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Digital Bulletin
              const Row(
                children: [
                  Icon(Icons.dashboard, color: AppTheme.accentGold),
                  SizedBox(width: 8),
                  Text('Digital Bulletin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletinItem(Icons.event, 'Upcoming: Youth Retreat (Aug 15)'),
                    const Divider(color: Colors.white10, height: 24),
                    _buildBulletinItem(Icons.live_tv, 'Watch Live: Sunday at 10 AM'),
                    const Divider(color: Colors.white10, height: 24),
                    _buildBulletinItem(Icons.favorite, 'Prayer Focus: Healing for our city'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // About Section
              const Text('About Us', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Welcome to our digital sanctuary. We are a Bible-believing community dedicated to loving God and loving people. Join us in person or online for worship, fellowship, and growth in the Word.',
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Service Times
              const Text('Service Times', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildServiceRow('Sunday Service', '10:00 AM EST'),
              _buildServiceRow('Wednesday Bible Study', '7:00 PM EST'),
              const SizedBox(height: 32),

              // Location
              const Text('Location', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('123 Grace Avenue\nNashville, TN 37203', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Maps...')));
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletinItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
        const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      ],
    );
  }

  Widget _buildServiceRow(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(time, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

