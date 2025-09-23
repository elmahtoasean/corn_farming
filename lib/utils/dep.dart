import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/controller/theme_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_constants.dart';

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreference = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreference);

  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()), fenix: true);

  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonString = await rootBundle
        .loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    Map<String, String> stringMap =
        jsonData.map((key, value) => MapEntry(key, value.toString()));
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
        stringMap;
  }

  return languages;
}


