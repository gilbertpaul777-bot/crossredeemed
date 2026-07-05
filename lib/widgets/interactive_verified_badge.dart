import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum BadgeType {
  user,
  church,
  leader
}

class InteractiveVerifiedBadge extends StatelessWidget {
  final BadgeType type;
  final double size;

  const InteractiveVerifiedBadge({
    super.key,
    required this.type,
    this.size = 20,
  });

  String get imagePath {
    switch (type) {
      case BadgeType.church:
        return 'assets/images/church_verified_badge.png';
      case BadgeType.leader:
        return 'assets/images/priest_pastor_verified_badge_v2.png';
      case BadgeType.user:
        return 'assets/images/verified_badge.png';
    }
  }

  String get title {
    switch (type) {
      case BadgeType.church:
        return 'Verified Church';
      case BadgeType.leader:
        return 'Verified Spiritual Leader';
      case BadgeType.user:
        return 'Verified Believer';
    }
  }

  String get description {
    switch (type) {
      case BadgeType.church:
        return 'This church has been verified by the CrossRedeemed team as an authentic, established congregation.';
      case BadgeType.leader:
        return 'This spiritual leader has undergone a background check and verification process for your safety and trust.';
      case BadgeType.user:
        return 'This user\'s identity has been verified by the CrossRedeemed community.';
    }
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.nebulaGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'badge_${type.name}',
                  child: Image.asset(imagePath, height: 150, width: 150),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context),
      child: Hero(
        tag: 'badge_${type.name}',
        child: Image.asset(
          imagePath,
          height: size,
          width: size,
        ),
      ),
    );
  }
}
