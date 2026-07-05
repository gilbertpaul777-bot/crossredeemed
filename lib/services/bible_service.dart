import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class BibleService {
  static List<dynamic>? _bibleData;
  static Future<void>? _loadFuture;

  /// Loads the entire KJV Bible JSON from assets into memory lazily.
  /// Call this before searching or reading chapters.
  static Future<void> loadBible() {
    if (_bibleData != null) return Future.value();
    _loadFuture ??= _doLoadBible();
    return _loadFuture!;
  }

  static Future<void> _doLoadBible() async {
    try {
      final jsonString = await rootBundle.loadString('assets/bible_kjv.json');
      // Using compute could prevent UI freezing, but jsonDecode works for now
      _bibleData = await compute(jsonDecode, jsonString) as List<dynamic>;
    } catch (e) {
      debugPrint('Error loading offline bible: $e');
    }
  }

  /// Returns the parsed JSON for a specific book and chapter.
  /// E.g. getChapter('John', 3) returns a list of verses.
  static Future<List<Map<String, dynamic>>> getChapter(String bookName, int chapterNum) async {
    await loadBible();
    if (_bibleData == null) return [];

    try {
      // Find the book
      final book = _bibleData!.firstWhere(
        (b) => (b['name'] as String).toLowerCase() == bookName.toLowerCase(),
        orElse: () => null,
      );

      if (book == null) return [];

      // The json structure has "chapters" which is an array of arrays of strings.
      // E.g. book['chapters'][0] is an array of strings for Chapter 1.
      final chapters = book['chapters'] as List<dynamic>;
      
      // Zero-indexed
      if (chapterNum < 1 || chapterNum > chapters.length) return [];
      
      final chapterVerses = chapters[chapterNum - 1] as List<dynamic>;
      
      List<Map<String, dynamic>> results = [];
      for (int i = 0; i < chapterVerses.length; i++) {
        results.add({
          'book': bookName,
          'chapter': chapterNum,
          'verse': i + 1,
          'text': chapterVerses[i].toString(),
        });
      }
      return results;
    } catch (e) {
      debugPrint('Error fetching chapter: $e');
      return [];
    }
  }

  /// Returns the next chapter as { 'book': String, 'chapter': int } or null if at the end of Revelation.
  static Future<Map<String, dynamic>?> getNextChapter(String currentBook, int currentChapter) async {
    await loadBible();
    if (_bibleData == null) return null;

    for (int i = 0; i < _bibleData!.length; i++) {
      if ((_bibleData![i]['name'] as String).toLowerCase() == currentBook.toLowerCase()) {
        final chapters = _bibleData![i]['chapters'] as List<dynamic>;
        if (currentChapter < chapters.length) {
          return {'book': _bibleData![i]['name'], 'chapter': currentChapter + 1};
        } else if (i + 1 < _bibleData!.length) {
          return {'book': _bibleData![i + 1]['name'], 'chapter': 1};
        }
      }
    }
    return null;
  }

  /// Returns the previous chapter as { 'book': String, 'chapter': int } or null if at Genesis 1.
  static Future<Map<String, dynamic>?> getPreviousChapter(String currentBook, int currentChapter) async {
    await loadBible();
    if (_bibleData == null) return null;

    for (int i = 0; i < _bibleData!.length; i++) {
      if ((_bibleData![i]['name'] as String).toLowerCase() == currentBook.toLowerCase()) {
        if (currentChapter > 1) {
          return {'book': _bibleData![i]['name'], 'chapter': currentChapter - 1};
        } else if (i > 0) {
          final prevChapters = _bibleData![i - 1]['chapters'] as List<dynamic>;
          return {'book': _bibleData![i - 1]['name'], 'chapter': prevChapters.length};
        }
      }
    }
    return null;
  }

  /// Returns the text for a specific verse.
  /// E.g. getVerse('John', 3, 16) returns "For God so loved the world..."
  static Future<String?> getVerse(String bookName, int chapterNum, int verseNum) async {
    final chapter = await getChapter(bookName, chapterNum);
    if (verseNum < 1 || verseNum > chapter.length) return null;
    return chapter[verseNum - 1]['text'] as String;
  }

  /// Searches the entire Bible for a keyword and returns max 30 results.
  static Future<List<Map<String, dynamic>>> searchKeyword(String keyword) async {
    await loadBible();
    if (_bibleData == null || keyword.trim().isEmpty) return [];

    final lowerKeyword = keyword.toLowerCase();
    List<Map<String, dynamic>> results = [];

    try {
      for (var book in _bibleData!) {
        final bookName = book['name'] as String;
        final chapters = book['chapters'] as List<dynamic>;
        
        for (int c = 0; c < chapters.length; c++) {
          final chapterVerses = chapters[c] as List<dynamic>;
          for (int v = 0; v < chapterVerses.length; v++) {
            final verseText = chapterVerses[v].toString();
            if (verseText.toLowerCase().contains(lowerKeyword)) {
              results.add({
                'book': bookName,
                'chapter': c + 1,
                'verse': v + 1,
                'text': verseText,
              });
              
              if (results.length >= 30) {
                return results;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching bible: $e');
    }
    
    return results;
  }
}
