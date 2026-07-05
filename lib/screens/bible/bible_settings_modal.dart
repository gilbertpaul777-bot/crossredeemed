import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cross_redeemed/providers/bible_settings_provider.dart';
import 'package:cross_redeemed/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class BibleSettingsModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.1),
                  AppTheme.surfaceDark.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.white10, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Consumer<BibleSettingsProvider>(
              builder: (context, settings, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reading Settings',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Font Size
                    _buildSectionHeader(Icons.text_fields, 'Text Size'),
                    Slider(
                      value: settings.fontSize,
                      min: 12.0,
                      max: 32.0,
                      divisions: 10,
                      activeColor: AppTheme.accentGold,
                      inactiveColor: Colors.white24,
                      onChanged: (val) => settings.setFontSize(val),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Background Color
                    _buildSectionHeader(Icons.color_lens, 'Background Color'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildThemeChip('Dark', 'dark', settings.themeMode, settings.setThemeMode)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildThemeChip('Light', 'light', settings.themeMode, settings.setThemeMode)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildThemeChip('Sepia', 'sepia', settings.themeMode, settings.setThemeMode)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildThemeChip('Cream', 'cream', settings.themeMode, settings.setThemeMode)),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Typography Options
                    _buildSectionHeader(Icons.font_download, 'Typography'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceChip(
                            'Ancient',
                            settings.fontFamily == 'Ancient',
                            () => settings.setFontFamily('Ancient'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildChoiceChip(
                            'Classic',
                            settings.fontFamily == 'Classic',
                            () => settings.setFontFamily('Classic'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildChoiceChip(
                            'Modern',
                            settings.fontFamily == 'Modern',
                            () => settings.setFontFamily('Modern'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Formatting Toggles
                    _buildSectionHeader(Icons.view_headline, 'Formatting'),
                    SwitchListTile(
                      title: const Text('Paragraph Mode', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Read like a novel', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      value: settings.isParagraphMode,
                      activeThumbColor: AppTheme.accentGold,
                      activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => settings.toggleParagraphMode(val),
                    ),

                    SwitchListTile(
                      title: const Text('Red Letter Words', style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Highlight Jesus' words in red", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      value: settings.isRedLetter,
                      activeThumbColor: AppTheme.accentGold,
                      activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => settings.toggleRedLetter(val),
                    ),
                    SwitchListTile(
                      title: const Text('Show Verse Numbers', style: TextStyle(color: Colors.white)),
                      value: settings.showVerseNumbers,
                      activeThumbColor: AppTheme.accentGold,
                      activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => settings.toggleVerseNumbers(val),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                );
              }
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentGold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  static Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.accentGold : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  static Widget _buildThemeChip(String label, String value, String currentValue, Function(String) onTap) {
    final isSelected = value == currentValue;
    
    // Determine colors for the chip based on the theme value
    Color bgColor;
    Color textColor;
    switch (value) {
      case 'light':
        bgColor = Colors.white;
        textColor = Colors.black87;
        break;
      case 'sepia':
        bgColor = const Color(0xFFF4ECD8);
        textColor = const Color(0xFF5B4636);
        break;
      case 'cream':
        bgColor = const Color(0xFFFDFBF7);
        textColor = const Color(0xFF333333);
        break;
      case 'dark':
      default:
        bgColor = AppTheme.backgroundDark;
        textColor = Colors.white;
        break;
    }

    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
