import 'package:get/get.dart';
import '../screens/language_screen.dart';
import '../home_page.dart';  
import '../screens/role_screen.dart';

class RouteHelper {
  static const String initial = '/language'; 
  static const String language = '/language';
  static const String home = '/home';
  static const String roleScreen = '/role_select';

  static String getInitialRoute() => language;
  static String getLanguageRoute() => language;
  static String getHomeRoute() => home;
  static String getRoleRoute() => roleScreen;

  static List<GetPage> routes = [
    GetPage(
      name: language,
      page: () => const LanguageScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
     GetPage(
      name: roleScreen,
      page: () => const RoleScreen(), 
    ),
  ];
}