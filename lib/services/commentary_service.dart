import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CommentaryService {
  static final CommentaryService _instance = CommentaryService._internal();
  factory CommentaryService() => _instance;
  CommentaryService._internal();

  final Map<String, dynamic> _commentaryData = {};
  final Set<String> _loadedBooks = {};

  Future<void> loadCommentary(String book) async {
    if (_loadedBooks.contains(book)) return;
    try {
      final url = Uri(path: '/mhc/$book.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        _commentaryData[book] = json.decode(utf8.decode(response.bodyBytes));
        _loadedBooks.add(book);
      } else {
        debugPrint('Failed to load commentary for $book: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading commentary for $book: $e');
    }
  }

  /// Retrieves commentary for a specific book and chapter.
  /// Structure depends on the final JSON format, usually Book -> Chapter -> Verse
  /// Returns a map of verse numbers to commentary text.
  Map<String, String> getCommentaryForChapter(String book, int chapter) {
    if (!_loadedBooks.contains(book)) return {};

    // Standard format fallback
    // e.g. _commentaryData[book][chapter.toString()] might be a Map of verses
    try {
      if (_commentaryData.containsKey(book)) {
        final bookData = _commentaryData[book];
        final chapterStr = chapter.toString();
        if (bookData.containsKey(chapterStr)) {
          final chapterData = bookData[chapterStr];
          
          if (chapterData is Map) {
             return chapterData.map((k, v) => MapEntry(k.toString(), v.toString()));
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing commentary structure: $e');
    }
    
    return {};
  }
}
