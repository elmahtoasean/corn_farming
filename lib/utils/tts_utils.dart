import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

const Map<String, List<String>> _languageFallbackCandidates = {
  'bn': [
    'bn-BD',
    'bn_BD',
    'bn-IN',
    'bn_IN',
    'bn',
    'bengali',
    'Bengali',
    'Bangla',
    'bangla',
  ],
};

const Map<String, List<String>> _voiceFallbackCandidates = {
  'bn': [
    'bn-BD',
    'bn_BD',
    'bn-IN',
    'bn_IN',
    'bn',
    'bengali',
    'Bengali',
    'Bangla',
    'bangla',
  ],
};

List<String> _deduplicatePreservingOrder(Iterable<String> items) {
  final seen = <String>{};
  final result = <String>[];
  for (final item in items) {
    final normalized = item.trim();
    if (normalized.isEmpty) {
      continue;
    }
    if (seen.add(normalized)) {
      result.add(normalized);
    }
  }
  return result;
}

Future<List<String>> _getAvailableLanguages(FlutterTts tts) async {
  try {
    final languages = await tts.getLanguages;
    if (languages is List) {
      return languages.map((lang) => lang.toString()).toList();
    }
  } catch (e) {
    print('Error getting available languages: $e');
  }
  return const [];
}

Future<bool> _isLanguageSupported(FlutterTts tts, String language) async {
  try {
    final result = await tts.isLanguageAvailable(language);
    if (result is bool) {
      return result;
    }
  } catch (e) {
    print('Error checking language support for $language: $e');
  }
  return false;
}

Future<bool> _supportsLanguage(FlutterTts tts, String language) async {
  final attempts = _deduplicatePreservingOrder([
    language,
    language.replaceAll('_', '-'),
    language.replaceAll('-', '_'),
  ]);

  for (final attempt in attempts) {
    final isSupported = await _isLanguageSupported(tts, attempt);
    if (isSupported) {
      print('Language $attempt is supported');
      return true;
    }
  }

  print('Language $language is not supported');
  return false;
}

String? _matchLanguage(List<String> available, List<String> candidates) {
  final normalizedMap = <String, String>{
    for (final lang in available) lang.toLowerCase(): lang,
  };

  // First, try exact matches
  for (final candidate in candidates) {
    final normalized = candidate.toLowerCase();
    final match = normalizedMap[normalized];
    if (match != null) {
      print('Found exact language match: $match for $candidate');
      return match;
    }
  }

  // Then try prefix matches
  for (final candidate in candidates) {
    final prefix = candidate.split(RegExp(r'[-_]')).first.toLowerCase();
    for (final available in normalizedMap.keys) {
      if (available.startsWith(prefix)) {
        final match = normalizedMap[available];
        if (match != null) {
          print('Found prefix language match: $match for $candidate');
          return match;
        }
      }
    }
  }

  // Finally try substring matches for Bengali
  if (candidates.any((c) => c.toLowerCase().contains('bn') || c.toLowerCase().contains('bengali'))) {
    for (final available in normalizedMap.keys) {
      if (available.contains('bn') || available.contains('bengali') || available.contains('bangla')) {
        final match = normalizedMap[available];
        if (match != null) {
          print('Found substring language match: $match');
          return match;
        }
      }
    }
  }

  return null;
}

Future<String> resolveTtsLanguage(
  FlutterTts tts,
  Locale? locale, {
  String defaultLanguage = 'en-US',
}) async {
  final availableLanguages = await _getAvailableLanguages(tts);
  
  print("Available TTS languages: $availableLanguages");

  final candidates = <String>[];
  if (locale != null) {
    final languageCode = locale.languageCode.toLowerCase();
    final countryCode = locale.countryCode;
    
    print("Resolving TTS for locale: $languageCode-$countryCode");
    
    // Special handling for Bengali
    if (languageCode == 'bn') {
      candidates.addAll(_languageFallbackCandidates['bn']!);
    } else {
      // General language handling
      if (countryCode != null && countryCode.isNotEmpty) {
        final normalizedCountry = countryCode.toUpperCase();
        candidates.add('${languageCode.toLowerCase()}-$normalizedCountry');
        candidates.add('${languageCode.toLowerCase()}_$normalizedCountry');
        candidates.add('${languageCode.toLowerCase()}-${countryCode.toLowerCase()}');
        candidates.add('${languageCode.toLowerCase()}_${countryCode.toLowerCase()}');
      }
      candidates.add(languageCode.toLowerCase());

      final fallback = _languageFallbackCandidates[languageCode.toLowerCase()];
      if (fallback != null) {
        candidates.addAll(fallback);
      }
    }
  }

  candidates.add(defaultLanguage);
  candidates.add(defaultLanguage.replaceAll('-', '_'));
  candidates.add(defaultLanguage.split('-').first);

  final dedupedCandidates = _deduplicatePreservingOrder(candidates);
  print("TTS language candidates: $dedupedCandidates");

  final matchedLanguage = _matchLanguage(availableLanguages, dedupedCandidates);
  if (matchedLanguage != null) {
    final isSupported = await _isLanguageSupported(tts, matchedLanguage);
    if (isSupported) {
      print("Selected TTS language: $matchedLanguage");
      return matchedLanguage;
    }
  }

  // Final fallback check
  for (final candidate in dedupedCandidates) {
    final isSupported = await _isLanguageSupported(tts, candidate);
    if (isSupported) {
      print("Fallback TTS language: $candidate");
      return candidate;
    }
  }

  print("Using default TTS language: $defaultLanguage");
  return defaultLanguage;
}

bool _didApplyLanguage(dynamic result) {
  if (result == null) {
    return true;
  }
  if (result is bool) {
    return result;
  }
  if (result is int) {
    return result == 1;
  }
  if (result is String) {
    return !result.toLowerCase().contains('error');
  }
  return true;
}

Future<String> configureTtsLanguage(
  FlutterTts tts,
  Locale? locale, {
  String defaultLanguage = 'en-US',
}) async {
  final resolved = await resolveTtsLanguage(tts, locale, defaultLanguage: defaultLanguage);
  print("Attempting to configure TTS with language: $resolved");

  final attempts = <String>[];

  void addAttempt(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      attempts.add(trimmed);
    }
  }

  addAttempt(resolved);
  addAttempt(resolved.replaceAll('_', '-'));
  addAttempt(resolved.replaceAll('-', '_'));

  if (locale != null) {
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      final upper = countryCode.toUpperCase();
      final lower = countryCode.toLowerCase();
      addAttempt('$languageCode-$upper');
      addAttempt('${languageCode}_$upper');
      addAttempt('$languageCode-$lower');
      addAttempt('${languageCode}_$lower');
    }
    addAttempt(languageCode);

    final fallbacks = _languageFallbackCandidates[languageCode.toLowerCase()] ?? const [];
    for (final candidate in fallbacks) {
      addAttempt(candidate);
    }
  }

  final defaultCandidates = [
    defaultLanguage,
    defaultLanguage.replaceAll('_', '-'),
    defaultLanguage.replaceAll('-', '_'),
    defaultLanguage.split(RegExp(r'[-_]')).first,
  ];

  for (final candidate in defaultCandidates) {
    addAttempt(candidate);
  }

  final dedupedAttempts = _deduplicatePreservingOrder(attempts);
  print("TTS configuration attempts: $dedupedAttempts");

  for (final candidate in dedupedAttempts) {
    final normalized = candidate.contains('_') ? candidate.replaceAll('_', '-') : candidate;
    final isSupported = await _supportsLanguage(tts, normalized);
    
    if (isSupported) {
      try {
        print("Attempting to set TTS language to: $normalized");
        final result = await tts.setLanguage(normalized);
        print("TTS setLanguage result: $result");
        
        if (_didApplyLanguage(result)) {
          // Verify the language was actually set
          try {
            final currentLang = await tts.getLanguages;
            print("Current TTS language after setting: $currentLang");
          } catch (e) {
            print("Could not verify current language: $e");
          }
          
          print("Successfully configured TTS language: $normalized");
          return normalized;
        }
      } catch (e) {
        print("Failed to set TTS language $normalized: $e");
        continue;
      }
    }
  }

  // Final fallback
  try {
    print("Falling back to default language: $defaultLanguage");
    await tts.setLanguage(defaultLanguage);
    return defaultLanguage;
  } catch (e) {
    print("Failed to set default language: $e");
    return defaultLanguage;
  }
}

Future<List<Map<String, String>>> _getAvailableVoices(FlutterTts tts) async {
  try {
    final voices = await tts.getVoices;
    if (voices is List) {
      return voices.whereType<Map>().map((voice) {
        return voice.map((key, value) => MapEntry(
              key.toString(),
              value?.toString() ?? '',
            ));
      }).toList();
    }
  } catch (e) {
    print('Error getting available voices: $e');
  }
  return const [];
}

bool _voiceMatchesCandidate(Map<String, String> voice, String candidate) {
  final locale = voice['locale']?.toLowerCase() ?? '';
  final name = voice['name']?.toLowerCase() ?? '';
  final normalizedCandidate = candidate.toLowerCase();
  
  if (locale == normalizedCandidate) {
    return true;
  }
  if (locale.replaceAll('_', '-') == normalizedCandidate.replaceAll('_', '-')) {
    return true;
  }
  if (name == normalizedCandidate || name.replaceAll('_', '-') == normalizedCandidate.replaceAll('_', '-')) {
    return true;
  }
  if (locale.startsWith(normalizedCandidate.split(RegExp(r'[-_]')).first)) {
    return true;
  }
  if (name.contains(normalizedCandidate)) {
    return true;
  }
  
  // Special Bengali matching
  if (normalizedCandidate.contains('bn') || normalizedCandidate.contains('bengali') || normalizedCandidate.contains('bangla')) {
    if (locale.contains('bn') || locale.contains('bengali') || locale.contains('bangla') ||
        name.contains('bn') || name.contains('bengali') || name.contains('bangla')) {
      return true;
    }
  }
  
  return false;
}

Future<Map<String, String>?> _findMatchingVoice(
  List<Map<String, String>> voices,
  List<String> candidates,
) async {
  print("Looking for voice among ${voices.length} voices with candidates: $candidates");
  
  for (final candidate in candidates) {
    for (final voice in voices) {
      if (_voiceMatchesCandidate(voice, candidate)) {
        final locale = voice['locale'];
        final name = voice['name'];
        if ((locale != null && locale.isNotEmpty) && (name != null && name.isNotEmpty)) {
          print("Found matching voice: $name ($locale) for candidate: $candidate");
          return {
            'locale': locale,
            'name': name,
          };
        }
      }
    }
  }
  
  print("No matching voice found for candidates: $candidates");
  return null;
}

Future<void> configureTtsVoice(
  FlutterTts tts,
  String languageCode, {
  Locale? locale,
}) async {
  final voices = await _getAvailableVoices(tts);
  if (voices.isEmpty) {
    print("No voices available");
    return;
  }

  print("Available voices: ${voices.length}");
  for (final voice in voices) {
    print("Voice: ${voice['name']} (${voice['locale']})");
  }

  final normalized = languageCode.toLowerCase();
  final candidates = <String>[
    languageCode,
    languageCode.replaceAll('_', '-'),
    languageCode.replaceAll('-', '_'),
    normalized,
  ];

  final languagePrefix = normalized.split(RegExp(r'[-_]')).first;
  candidates.add(languagePrefix);

  final localeFallback = locale != null
      ? _voiceFallbackCandidates[locale.languageCode.toLowerCase()]
      : null;
  if (localeFallback != null) {
    candidates.addAll(localeFallback);
  } else {
    final prefixFallback = _voiceFallbackCandidates[languagePrefix.toLowerCase()];
    if (prefixFallback != null) {
      candidates.addAll(prefixFallback);
    }
  }

  final dedupedCandidates = _deduplicatePreservingOrder(candidates);
  final voice = await _findMatchingVoice(voices, dedupedCandidates);
  
  if (voice != null) {
    try {
      print("Setting TTS voice: ${voice['name']} (${voice['locale']})");
      await tts.setVoice(voice);
      print("Successfully set TTS voice");
    } catch (e) {
      print("Failed to set TTS voice: $e");
    }
  } else {
    print("No suitable voice found for language: $languageCode");
  }
}

// Debug function to test Bengali TTS
Future<void> debugBengaliTTS(FlutterTts tts) async {
  print("=== Bengali TTS Debug ===");
  
  try {
    // Get available languages
    final languages = await _getAvailableLanguages(tts);
    print("Available languages: $languages");
    
    // Check for Bengali languages
    final bengaliLanguages = languages.where((lang) =>
        lang.toLowerCase().contains('bn') ||
        lang.toLowerCase().contains('bengali') ||
        lang.toLowerCase().contains('bangla')).toList();
    print("Bengali languages found: $bengaliLanguages");
    
    // Get available voices
    final voices = await _getAvailableVoices(tts);
    final bengaliVoices = voices.where((voice) =>
        voice['locale']?.toLowerCase().contains('bn') == true ||
        voice['locale']?.toLowerCase().contains('bengali') == true ||
        voice['name']?.toLowerCase().contains('bengali') == true).toList();
    print("Bengali voices found: $bengaliVoices");
    
    // Test language setting
    for (final lang in ['bn-BD', 'bn-IN', 'bn', 'bengali']) {
      try {
        final result = await tts.setLanguage(lang);
        print("setLanguage('$lang') result: $result");
        
        final isAvailable = await tts.isLanguageAvailable(lang);
        print("isLanguageAvailable('$lang'): $isAvailable");
      } catch (e) {
        print("Error testing language '$lang': $e");
      }
    }
    
  } catch (e) {
    print("Debug error: $e");
  }
  
  print("=== End Bengali TTS Debug ===");
}

// Simple test function
Future<void> testBengaliTTS(FlutterTts tts) async {
  try {
    print("Testing Bengali TTS...");
    
    // Configure for Bengali
    final language = await configureTtsLanguage(tts, const Locale('bn', 'BD'));
    await configureTtsVoice(tts, language, locale: const Locale('bn', 'BD'));
    
    // Set speech parameters
    await tts.setVolume(1.0);
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    
    // Test with simple Bengali text
    print("Speaking Bengali text...");
    await tts.speak('হ্যালো। এটি একটি পরীক্ষা।');
    
  } catch (e) {
    print("Bengali TTS test failed: $e");
  }
}