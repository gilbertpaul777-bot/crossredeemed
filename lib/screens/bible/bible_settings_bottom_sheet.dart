import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bible_settings_provider.dart';
import '../../theme/app_theme.dart';

class BibleSettingsBottomSheet extends StatelessWidget {
  const BibleSettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const BibleSettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<BibleSettingsProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Reading Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Font Size Slider
            const Text('Font Size', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Row(
              children: [
                const Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
                Expanded(
                  child: Slider(
                    value: settings.fontSize,
                    min: 12.0,
                    max: 36.0,
                    activeColor: AppTheme.primaryPurple,
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      context.read<BibleSettingsProvider>().setFontSize(val);
                    },
                  ),
                ),
                const Text('A', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            // Toggles
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Red Letter Text', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Highlight words of Jesus in red', style: TextStyle(color: Colors.white54, fontSize: 12)),
              activeThumbColor: AppTheme.primaryPurple,
              value: settings.isRedLetter,
              onChanged: (val) {
                context.read<BibleSettingsProvider>().toggleRedLetter(val);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Verse Numbers', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Show verse numbers in the text', style: TextStyle(color: Colors.white54, fontSize: 12)),
              activeThumbColor: AppTheme.primaryPurple,
              value: settings.showVerseNumbers,
              onChanged: (val) {
                context.read<BibleSettingsProvider>().toggleVerseNumbers(val);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paragraph Mode', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Continuous text vs Verse-by-verse list', style: TextStyle(color: Colors.white54, fontSize: 12)),
              activeThumbColor: AppTheme.primaryPurple,
              value: settings.isParagraphMode,
              onChanged: (val) {
                context.read<BibleSettingsProvider>().toggleParagraphMode(val);
              },
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            // Background Theme
            const Text('Theme', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeChip(context, 'dark', 'Dark', Colors.black, Colors.white),
                _buildThemeChip(context, 'light', 'Light', Colors.white, Colors.black),
                _buildThemeChip(context, 'sepia', 'Sepia', const Color(0xFFF4ECD8), const Color(0xFF5B4636)),
                _buildThemeChip(context, 'cream', 'Cream', const Color(0xFFFDFBF7), const Color(0xFF333333)),
              ],
            ),

            const SizedBox(height: 24),

            // Font Family
            const Text('Font', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFontChip(context, 'Serif', 'Classic'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFontChip(context, 'Sans-Serif', 'Modern'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip(BuildContext context, String mode, String label, Color bgColor, Color textColor) {
    final settings = context.watch<BibleSettingsProvider>();
    final isSelected = settings.themeMode == mode;

    return GestureDetector(
      onTap: () => context.read<BibleSettingsProvider>().setThemeMode(mode),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildFontChip(BuildContext context, String font, String label) {
    final settings = context.watch<BibleSettingsProvider>();
    final isSelected = settings.fontFamily == font;

    return GestureDetector(
      onTap: () => context.read<BibleSettingsProvider>().setFontFamily(font),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withValues(alpha: 0.2) : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryPurple : Colors.white,
              fontWeight: FontWeight.bold,
              // Use standard fonts to denote the choice roughly
              fontFamily: font == 'Serif' ? 'Georgia' : 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
