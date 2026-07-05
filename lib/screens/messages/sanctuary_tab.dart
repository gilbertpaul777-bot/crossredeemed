import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'leader_profile_screen.dart';

class SanctuaryTab extends StatelessWidget {
  const SanctuaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Verified Spiritual Leaders
    final List<Map<String, dynamic>> mockLeaders = [
      {
        'id': 'leader-1',
        'name': 'Pastor Michael Davis',
        'denomination': 'Non-Denominational',
        'status': 'Available Now',
        'avatar_url': 'https://i.pravatar.cc/150?u=michael',
        'experience': '15 Years',
        'specialties': ['Marriage Counseling', 'Spiritual Doubt', 'Grief'],
        'church_name': 'Grace Fellowship Church',
      },
      {
        'id': 'leader-2',
        'name': 'Father Thomas O\'Brien',
        'denomination': 'Catholic',
        'status': 'Busy',
        'avatar_url': 'https://i.pravatar.cc/150?u=thomas',
        'experience': '22 Years',
        'specialties': ['Confession', 'Addiction Recovery', 'Family'],
        'church_name': 'St. Jude Parish',
      },
      {
        'id': 'leader-3',
        'name': 'Reverend Sarah Jenkins',
        'denomination': 'Methodist',
        'status': 'Offline',
        'avatar_url': 'https://i.pravatar.cc/150?u=sarah',
        'experience': '8 Years',
        'specialties': ['Youth Ministry', 'Anxiety', 'Grief'],
        'church_name': 'First United Methodist',
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black12,
          child: const Row(
            children: [
              Icon(Icons.shield, color: AppTheme.accentGold, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All leaders are verified and background-checked for your safety.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mockLeaders.length,
            itemBuilder: (context, index) {
              final leader = mockLeaders[index];
              final isAvailable = leader['status'] == 'Available Now';
              final isBusy = leader['status'] == 'Busy';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(leader['avatar_url']),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable ? Colors.green : (isBusy ? Colors.orange : Colors.grey),
                          border: Border.all(color: AppTheme.surfaceDark, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(leader['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 4),
                    Image.asset('assets/images/priest_pastor_verified_badge_v2.png', height: 24, width: 24),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leader['denomination'], style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      leader['status'],
                      style: TextStyle(
                        color: isAvailable ? Colors.green : (isBusy ? Colors.orange : Colors.grey),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaderProfileScreen(leaderData: leader),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
