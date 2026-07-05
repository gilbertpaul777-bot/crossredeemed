import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home/home_feed_screen.dart';
import 'bible/bible_home_screen.dart';
import 'create/record_video_screen.dart';
import 'faith_wall/faith_wall_feed_screen.dart';
import 'profile/my_profile_screen.dart';
import '../widgets/ichthys_icon.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/guest_modal.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeFeedScreen(),
    const BibleHomeScreen(),
    const RecordVideoScreen(),
    const FaithWallFeedScreen(),
    const MyProfileScreen(),
  ];

  void _onItemTapped(int index) {
    final isGuest = Supabase.instance.client.auth.currentUser == null;
    if (isGuest && (index == 2 || index == 4)) {
      GuestModal.show(context);
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        final showLabels = constraints.maxWidth >= 800;

        final bottomNavItems = [
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.church),
            activeIcon: FaIcon(FontAwesomeIcons.church),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bookBible),
            activeIcon: FaIcon(FontAwesomeIcons.bookBible),
            label: 'Bible',
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.cross, size: 36)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms)
                .tint(color: AppTheme.accentGold.withValues(alpha: 0.5)),
            activeIcon: const FaIcon(FontAwesomeIcons.cross, size: 36)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms)
                .tint(color: AppTheme.accentGold),
            label: 'Create',
          ),
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.dove),
            activeIcon: FaIcon(FontAwesomeIcons.dove),
            label: 'Faith Wall',
          ),
          const BottomNavigationBarItem(
            icon: IchthysIcon(size: 36),
            activeIcon: IchthysIcon(size: 36, strokeWidth: 5.0),
            label: 'Profile',
          ),
        ];

        final railDestinations = [
          const NavigationRailDestination(
            icon: FaIcon(FontAwesomeIcons.church),
            selectedIcon: FaIcon(FontAwesomeIcons.church),
            label: Text('Home'),
          ),
          const NavigationRailDestination(
            icon: FaIcon(FontAwesomeIcons.bookBible),
            selectedIcon: FaIcon(FontAwesomeIcons.bookBible),
            label: Text('Bible'),
          ),
          NavigationRailDestination(
            icon: const FaIcon(FontAwesomeIcons.cross, size: 36)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms)
                .tint(color: AppTheme.accentGold.withValues(alpha: 0.5)),
            selectedIcon: const FaIcon(FontAwesomeIcons.cross, size: 36)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms)
                .tint(color: AppTheme.accentGold),
            label: const Text('Create'),
          ),
          const NavigationRailDestination(
            icon: FaIcon(FontAwesomeIcons.dove),
            selectedIcon: FaIcon(FontAwesomeIcons.dove),
            label: Text('Faith Wall'),
          ),
          const NavigationRailDestination(
            icon: IchthysIcon(size: 36),
            selectedIcon: IchthysIcon(size: 36, strokeWidth: 5.0),
            label: Text('Profile'),
          ),
        ];

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.nebulaGradient,
            ),
            child: SafeArea(
              child: isDesktop
                  ? Row(
                      children: [
                        NavigationRail(
                          backgroundColor: Colors.black.withValues(alpha: 0.2),
                          selectedIndex: _currentIndex,
                          onDestinationSelected: _onItemTapped,
                          extended: showLabels,
                          unselectedIconTheme: const IconThemeData(color: Colors.white54),
                          selectedIconTheme: const IconThemeData(color: Colors.white),
                          unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
                          selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          destinations: railDestinations,
                        ),
                        const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
                        Expanded(child: _pages[_currentIndex]),
                      ],
                    )
                  : _pages[_currentIndex],
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : BottomNavigationBar(
                  backgroundColor: AppTheme.primaryPurple,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _currentIndex,
                  onTap: _onItemTapped,
                  items: bottomNavItems,
                ),
        );
      },
    );
  }
}
