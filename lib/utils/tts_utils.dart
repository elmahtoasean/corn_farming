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

List<String> _expandLanguageVariants(String code) {
  final trimmed = code.trim();
  if (trimmed.isEmpty) {
    return const [];
  }

  final variants = <String>[];
  final normalized = trimmed.replaceAll(' ', '');
  final hyphenated = normalized.replaceAll('_', '-');
  final underscored = normalized.replaceAll('-', '_');

  final parts = hyphenated.split('-');
  final language = parts.isNotEmpty ? parts.first.toLowerCase() : normalized;
  final region = parts.length >= 2 ? parts[1] : '';
  final regionUpper = region.toUpperCase();

  void addVariant(String value) {
    if (value.trim().isEmpty) {
      return;
    }
    variants.add(value.trim());
  }

  addVariant(trimmed);
  addVariant(normalized);
  addVariant(hyphenated);
  addVariant(underscored);

  if (region.isNotEmpty) {
    addVariant('${language}_$regionUpper');
    addVariant('${language}-$regionUpper');
    addVariant('${language}_${region.toLowerCase()}');
    addVariant('${language}-${region.toLowerCase()}');
  }

  addVariant(language);

  return _deduplicatePreservingOrder(variants);
}

Future<bool> _trySetLanguage(FlutterTts tts, String language) async {
  try {
    final result = await tts.setLanguage(language);
    if (result is bool) {
      return result;
    }
    if (result is int) {
      return result == 1;
    }
    return true;
  } catch (_) {
    return false;
  }
}

List<String> _buildLanguageCandidates(
  String languageCode, {
  Locale? locale,
  required String defaultLanguage,
}) {
  final candidates = <String>[];

  void addFromCode(String code) {
    if (code.trim().isEmpty) {
      return;
    }
    candidates.addAll(_expandLanguageVariants(code));
  }

  addFromCode(languageCode);

  if (locale != null) {
    final language = locale.languageCode;
    final country = locale.countryCode;
    if (country != null && country.isNotEmpty) {
      final normalizedCountryUpper = country.toUpperCase();
      addFromCode('${language}_$normalizedCountryUpper');
      addFromCode('${language}-$normalizedCountryUpper');
      addFromCode('${language}_${country.toLowerCase()}');
      addFromCode('${language}-${country.toLowerCase()}');
    }
    addFromCode(language);

    final fallback = _languageFallbackCandidates[language.toLowerCase()];
    if (fallback != null) {
      for (final code in fallback) {
        addFromCode(code);
      }
    }
  }

  addFromCode(defaultLanguage);
  final defaultPrefix = defaultLanguage.split(RegExp(r'[-_]')).first;
  addFromCode(defaultPrefix);

  return _deduplicatePreservingOrder(candidates);
}

Future<String> applyTtsLanguage(
  FlutterTts tts,
  String languageCode, {
  Locale? locale,
  String defaultLanguage = 'en-US',
}) async {
  final effectiveCode = languageCode.trim().isEmpty
      ? defaultLanguage
      : languageCode.trim();

  final candidates = _buildLanguageCandidates(
    effectiveCode,
    locale: locale,
    defaultLanguage: defaultLanguage,
  );

  for (final candidate in candidates) {
    if (await _trySetLanguage(tts, candidate)) {
      return candidate;
    }
  }

  await _trySetLanguage(tts, defaultLanguage);
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
