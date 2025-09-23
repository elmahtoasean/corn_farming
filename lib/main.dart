import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/controller/theme_controller.dart';
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
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizationController) {
            final ColorScheme lightScheme = ColorScheme.fromSeed(
              seedColor: customSwatch,
              primary: customSwatch.shade600,
              secondary: const Color(0xFFF6B042),
              surface: const Color(0xFFFDF3D9),
              background: const Color(0xFFF9F3E5),
            );
            final ColorScheme darkScheme = ColorScheme.fromSeed(
              seedColor: customSwatch,
              primary: customSwatch.shade300,
              secondary: const Color(0xFFFFD37A),
              surface: const Color(0xFF1F2A17),
              background: const Color(0xFF141C10),
              brightness: Brightness.dark,
            );
            return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: lightScheme.surface,
            canvasColor: lightScheme.surface,
            cardColor: Colors.white,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: lightScheme.onBackground,
                  displayColor: lightScheme.onBackground,
                ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: lightScheme.onSurface,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: lightScheme.onSurface,
                  ),
            ),
            cardTheme: CardThemeData(
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: lightScheme.primary.withOpacity(0.3)),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: lightScheme.primary,
              foregroundColor: lightScheme.onPrimary,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkScheme.surface,
            canvasColor: darkScheme.surface,
            cardColor: darkScheme.surface,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: darkScheme.onBackground,
                  displayColor: darkScheme.onBackground,
                ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: darkScheme.onSurface,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: darkScheme.onSurface,
                  ),
            ),
            cardTheme: CardThemeData(
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 10,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: darkScheme.primary.withOpacity(0.4)),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: darkScheme.primary,
              foregroundColor: darkScheme.onPrimary,
            ),
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
      },
    );
  }
}
