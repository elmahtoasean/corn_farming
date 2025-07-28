import 'package:corn_farming/models/language_model.dart';

class AppConstants {
  static const String COUNTRY_CODE = 'country_code';
  static const String LANGUAGE_CODE = 'language_code';

  static List<LanguageModel> languages = [
	LanguageModel(
	  imageUrl: "en.png",
	  languageName: 'English',
	  countryCode: 'US',
	  languageCode: 'en',
	),
	LanguageModel(
	  imageUrl: "bn.png",
	  languageName: 'Bengali',
	  countryCode: 'BD',
	  languageCode: 'bn',
	),
  ];
}
