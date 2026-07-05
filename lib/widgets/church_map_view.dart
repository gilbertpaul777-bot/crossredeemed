import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/messages/verified_church_screen.dart';
import 'dart:math';

class ChurchMapView extends StatelessWidget {
  final List<Map<String, dynamic>> churches;

  const ChurchMapView({super.key, required this.churches});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppTheme.backgroundDark, // Map base color
          child: Stack(
            children: [
              // 1. Mock Map Background Grid
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _MapGridPainter(),
              ),

              // 2. Simulated Current Location Indicator (Center)
              Positioned(
                left: constraints.maxWidth / 2 - 20,
                top: constraints.maxHeight / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Church Pins
              ...churches.asMap().entries.map((entry) {
                final index = entry.key;
                final church = entry.value;
                
                // Deterministic pseudorandom placement around the center
                final random = Random(index * 100);
                final angle = random.nextDouble() * 2 * pi;
                final distance = 40 + random.nextDouble() * (min(constraints.maxWidth, constraints.maxHeight) / 2 - 60);
                
                final dx = constraints.maxWidth / 2 + distance * cos(angle) - 24; // offset pin size
                final dy = constraints.maxHeight / 2 + distance * sin(angle) - 48; // offset pin height
                
                return Positioned(
                  left: dx,
                  top: dy,
                  child: GestureDetector(
                    onTap: () => _showChurchPreview(context, church),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark.withAlpha(200),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                          ),
                          child: Text(
                            church['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.accentGold,
                          size: 40,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showChurchPreview(BuildContext context, Map<String, dynamic> church) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryPurple,
                    child: Icon(Icons.church, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                church['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.asset('assets/images/church_verified_badge.png', height: 24, width: 24),
                          ],
                        ),
                        Text(church['denomination'] ?? 'Non-Denominational', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  Text(
                    church['distance'],
                    style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerifiedChurchScreen(
                          churchName: church['name'],
                          denomination: church['denomination'] ?? 'Non-Denominational',
                          churchData: church,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Church Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..strokeWidth = 1.0;

    const gridSize = 40.0;
    
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Add some random "roads" for visual flair
    final roadPaint = Paint()
      ..color = AppTheme.primaryPurple.withAlpha(20)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
      
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width, size.height * 0.1);
    
    path.moveTo(size.width * 0.1, size.height);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.8, 0);
    
    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
