import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class StrongsService {
  static Map<String, dynamic>? _dictionaryData;
  static List<dynamic>? _interlinearData;
  static Future<void>? _loadDictFuture;
  static Future<void>? _loadInterlinearFuture;

  /// Loads the Strongs Dictionary
  static Future<void> loadDictionary() {
    if (_dictionaryData != null) return Future.value();
    _loadDictFuture ??= _doLoadDictionary();
    return _loadDictFuture!;
  }

  static Future<void> _doLoadDictionary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/strongs_dictionary.json');
      _dictionaryData = await compute(jsonDecode, jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading strongs dictionary: $e');
    }
  }

  /// Loads the KJV Interlinear dataset
  static Future<void> loadInterlinear() {
    if (_interlinearData != null) return Future.value();
    _loadInterlinearFuture ??= _doLoadInterlinear();
    return _loadInterlinearFuture!;
  }

  static Future<void> _doLoadInterlinear() async {
    try {
      debugPrint('StrongsService: Loading kjv_strongs.json...');
      final jsonString = await rootBundle.loadString('assets/kjv_strongs.json');
      debugPrint('StrongsService: Loaded JSON string of length ${jsonString.length}');
      _interlinearData = jsonDecode(jsonString) as List<dynamic>;
      debugPrint('StrongsService: Parsed JSON, got ${_interlinearData?.length} entries');
    } catch (e) {
      debugPrint('Error loading interlinear bible: $e');
    }
  }

  /// Gets the definition for a Strong's number (e.g. 'h7225' or 'H7225')
  static Future<Map<String, dynamic>?> getDefinition(String strongsNumber) async {
    await loadDictionary();
    if (_dictionaryData == null) return null;
    return _dictionaryData![strongsNumber.toLowerCase()];
  }

  /// Gets the interlinear verse data for a specific book, chapter, and verse
  static Future<List<dynamic>?> getInterlinearVerse(String book, int chapter, int verse) async {
    await loadInterlinear();
    if (_interlinearData == null) return null;
    
    // Format is like "kjv:Genesis:1:1"
    final targetRef = 'kjv:$book:$chapter:$verse'.toLowerCase();
    
    for (var entry in _interlinearData!) {
      if (entry['r'] != null && (entry['r'] as String).toLowerCase() == targetRef) {
        return entry['d'] as List<dynamic>?;
      }
    }
    return null;
  }
  
  /// Gets a whole chapter of interlinear data
  static Future<List<Map<String, dynamic>>> getInterlinearChapter(String book, int chapter) async {
    await loadInterlinear();
    if (_interlinearData == null) return [];
    
    final prefix = 'kjv:$book:$chapter:'.toLowerCase();
    List<Map<String, dynamic>> verses = [];
    
    for (var entry in _interlinearData!) {
      if (entry['r'] != null) {
        String ref = (entry['r'] as String).toLowerCase();
        if (ref.startsWith(prefix)) {
          // Extract verse number
          final parts = ref.split(':');
          if (parts.length >= 4) {
             final vNum = int.tryParse(parts[3]);
             if (vNum != null) {
               verses.add({
                 'verse': vNum,
                 'data': entry['d'],
               });
             }
          }
        }
      }
    }
    
    // Sort by verse number just in case
    verses.sort((a, b) => (a['verse'] as int).compareTo(b['verse'] as int));
    debugPrint('StrongsService: Found ${verses.length} verses for $book $chapter. Prefix was $prefix');
    return verses;
  }
}
