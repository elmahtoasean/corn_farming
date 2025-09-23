import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  }

  candidates.add(defaultLanguage);
  candidates.add(defaultLanguage.replaceAll('-', '_'));
  candidates.add(defaultLanguage.split('-').first);

  final matchedLanguage = _matchLanguage(availableLanguages, candidates);
  if (matchedLanguage != null &&
      await _isLanguageSupported(tts, matchedLanguage)) {
    return matchedLanguage;
  }

  for (final candidate in candidates) {
    if (await _isLanguageSupported(tts, candidate)) {
      return candidate;
    }
  }

  return defaultLanguage;
}
