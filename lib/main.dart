import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/utils/app_constants.dart';
import 'package:corn_farming/utils/app_route.dart';
import 'package:corn_farming/utils/messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:corn_farming/utils/dep.dart' as dep;
import 'package:corn_farming/utils/material_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<String, Map<String, String>> languages = await dep.init();
  runApp(MyApp(languages: languages));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;

  const MyApp({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizationController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: customSwatch,
            cardColor: customSwatch[500],
          ),
          translations: Messages(languages: languages),
          locale: localizationController.locale,
          fallbackLocale: Locale(
            AppConstants.languages[0].languageCode,
            AppConstants.languages[0].countryCode,
          ),
          initialRoute: RouteHelper.getInitialRoute(),
          getPages: RouteHelper.routes,
        );
      },
    );
  }
}
