import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleSettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Defaults
  double _fontSize = 18.0;
  String _themeMode = 'dark'; // 'dark', 'light', 'sepia', 'cream'
  bool _isRedLetter = true;
  bool _showVerseNumbers = true;
  bool _isParagraphMode = true; // Add paragraph mode
  String _fontFamily = 'Classic'; // 'Ancient', 'Classic', 'Modern'

  // Getters
  double get fontSize => _fontSize;
  String get themeMode => _themeMode;
  bool get isRedLetter => _isRedLetter;
  bool get showVerseNumbers => _showVerseNumbers;
  bool get isParagraphMode => _isParagraphMode;
  String get fontFamily => _fontFamily;

  BibleSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _fontSize = _prefs?.getDouble('bible_fontSize') ?? 18.0;
    _themeMode = _prefs?.getString('bible_themeMode') ?? 'dark';
    _isRedLetter = _prefs?.getBool('bible_isRedLetter') ?? true;
    _showVerseNumbers = _prefs?.getBool('bible_showVerseNumbers') ?? true;
    _isParagraphMode = _prefs?.getBool('bible_isParagraphMode') ?? true;
    _fontFamily = _prefs?.getString('bible_fontFamily') ?? 'Classic';
    notifyListeners();
  }

  // Setters
  void setFontSize(double size) {
    _fontSize = size;
    _prefs?.setDouble('bible_fontSize', size);
    notifyListeners();
  }

  void setThemeMode(String theme) {
    _themeMode = theme;
    _prefs?.setString('bible_themeMode', theme);
    notifyListeners();
  }

  void toggleRedLetter(bool value) {
    _isRedLetter = value;
    _prefs?.setBool('bible_isRedLetter', value);
    notifyListeners();
  }

  void toggleVerseNumbers(bool value) {
    _showVerseNumbers = value;
    _prefs?.setBool('bible_showVerseNumbers', value);
    notifyListeners();
  }

  void toggleParagraphMode(bool value) {
    _isParagraphMode = value;
    _prefs?.setBool('bible_isParagraphMode', value);
    notifyListeners();
  }

  void setFontFamily(String font) {
    _fontFamily = font;
    _prefs?.setString('bible_fontFamily', font);
    notifyListeners();
  }
}
