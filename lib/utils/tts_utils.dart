import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

const Map<String, List<String>> _languageFallbackCandidates = {
  'bn': [
    'bn-BD',
    'bn_BD',
    'bn-IN',
    'bn_IN',
    'bn',
  ],
};

const Map<String, List<String>> _voiceFallbackCandidates = {
  'bn': [
    'bn-BD',
    'bn_BD',
    'bn-IN',
    'bn_IN',
    'bn',
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
  } catch (_) {}
  return const [];
}

Future<bool> _isLanguageSupported(FlutterTts tts, String language) async {
  try {
    final result = await tts.isLanguageAvailable(language);
    if (result is bool) {
      return result;
    }
  } catch (_) {}
  return true;
}

String? _matchLanguage(List<String> available, List<String> candidates) {
  final normalizedMap = <String, String>{
    for (final lang in available) lang.toLowerCase(): lang,
  };

  for (final candidate in candidates) {
    final normalized = candidate.toLowerCase();
    final match = normalizedMap[normalized];
    if (match != null) {
      return match;
    }
  }

  for (final candidate in candidates) {
    final prefix = candidate.split(RegExp(r'[-_]')).first.toLowerCase();
    final match = available.firstWhere(
      (lang) => lang.toLowerCase().startsWith(prefix),
      orElse: () => '',
    );
    if (match.isNotEmpty) {
      return match;
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

  final candidates = <String>[];
  if (locale != null) {
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      final normalizedCountry = countryCode.toUpperCase();
      candidates.add('${languageCode.toLowerCase()}-$normalizedCountry');
      candidates.add('${languageCode.toLowerCase()}_$normalizedCountry');
      candidates.add('${languageCode.toLowerCase()}-${countryCode.toLowerCase()}');
      candidates.add('${languageCode.toLowerCase()}_${countryCode.toLowerCase()}');
    }
    candidates.add(languageCode.toLowerCase());

    final fallback =
        _languageFallbackCandidates[languageCode.toLowerCase()];
    if (fallback != null) {
      candidates.addAll(fallback);
    }
  }

  candidates.add(defaultLanguage);
  candidates.add(defaultLanguage.replaceAll('-', '_'));
  candidates.add(defaultLanguage.split('-').first);

  final dedupedCandidates = _deduplicatePreservingOrder(candidates);

  final matchedLanguage =
      _matchLanguage(availableLanguages, dedupedCandidates);
  if (matchedLanguage != null &&
      await _isLanguageSupported(tts, matchedLanguage)) {
    return matchedLanguage;
  }

  for (final candidate in dedupedCandidates) {
    if (await _isLanguageSupported(tts, candidate)) {
      return candidate;
    }
  }

  return defaultLanguage;
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
  } catch (_) {}
  return const [];
}

bool _voiceMatchesCandidate(Map<String, String> voice, String candidate) {
  final locale = voice['locale']?.toLowerCase() ?? '';
  final name = voice['name']?.toLowerCase() ?? '';
  final normalizedCandidate = candidate.toLowerCase();
  if (locale == normalizedCandidate) {
    return true;
  }
  if (locale.replaceAll('_', '-') ==
      normalizedCandidate.replaceAll('_', '-')) {
    return true;
  }
  if (name == normalizedCandidate ||
      name.replaceAll('_', '-') ==
          normalizedCandidate.replaceAll('_', '-')) {
    return true;
  }
  if (locale.startsWith(normalizedCandidate.split(RegExp(r'[-_]')).first)) {
    return true;
  }
  if (name.contains(normalizedCandidate)) {
    return true;
  }
  return false;
}

Future<Map<String, String>?> _findMatchingVoice(
  List<Map<String, String>> voices,
  List<String> candidates,
) async {
  for (final candidate in candidates) {
    for (final voice in voices) {
      if (_voiceMatchesCandidate(voice, candidate)) {
        final locale = voice['locale'];
        final name = voice['name'];
        if ((locale != null && locale.isNotEmpty) &&
            (name != null && name.isNotEmpty)) {
          return {
            'locale': locale,
            'name': name,
          };
        }
      }
    }
  }
  return null;
}

Future<void> configureTtsVoice(
  FlutterTts tts,
  String languageCode, {
  Locale? locale,
}) async {
  final voices = await _getAvailableVoices(tts);
  if (voices.isEmpty) {
    return;
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
    final prefixFallback =
        _voiceFallbackCandidates[languagePrefix.toLowerCase()];
    if (prefixFallback != null) {
      candidates.addAll(prefixFallback);
    }
  }

  final dedupedCandidates = _deduplicatePreservingOrder(candidates);
  final voice = await _findMatchingVoice(voices, dedupedCandidates);
  if (voice != null) {
    try {
      await tts.setVoice(voice);
    } catch (_) {}
  }
}
