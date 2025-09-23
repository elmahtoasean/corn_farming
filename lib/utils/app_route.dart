import 'package:get/get.dart';

import 'package:corn_farming/screens/language_screen.dart';
import 'package:corn_farming/home_page.dart';
import 'package:corn_farming/screens/role_screen.dart';

import 'package:corn_farming/screens/tool_guide.dart';
import 'package:corn_farming/screens/soil_type.dart';
import 'package:corn_farming/utils/help.dart';
import 'package:corn_farming/utils/seed_type.dart';
import 'package:corn_farming/screens/profile_overview.dart';
import 'package:corn_farming/screens/alerts_screen.dart';
import 'package:corn_farming/screens/planner_screen.dart';

import 'package:corn_farming/screens/tool_guide.dart';
import 'package:corn_farming/screens/corn_facts.dart';
import 'package:corn_farming/screens/growth_conditions.dart';
import 'package:corn_farming/screens/watering_info.dart';
import 'package:corn_farming/screens/pest_management.dart';
import 'package:corn_farming/screens/nursing_plants.dart';
import 'package:corn_farming/screens/growing_plants.dart';
import 'package:corn_farming/screens/flowering_plants.dart';
import 'package:corn_farming/screens/ripe_corns.dart';
import 'package:corn_farming/screens/collecting_corns.dart';
import 'package:corn_farming/screens/marketing_corns.dart';

class RouteHelper {
  static const String initial = '/language';
  static const String language = '/language';
  static const String home = '/home';
  static const String roleScreen = '/role_select';

  static const String userInfo = '/user-info';
  static const String soilType = '/soil-type';
  static const String seedType = '/seed-type';
  static const String help = '/help';

  static const String cornFacts = '/corn-facts';
  static const String toolGuide = '/tool-guide';
  static const String growthConditions = '/growth-conditions';
  static const String wateringInfo = '/watering-info';
  static const String pestManagement = '/pest-management';
  static const String nursingPlants = '/nursing-plants';
  static const String growingPlants = '/growing-plants';
  static const String floweringPlants = '/flowering-plants';
  static const String ripeCorns = '/ripe-corns';
  static const String collectingCorns = '/collecting-corns';
  static const String marketingCorns = '/marketing-corns';
  static const String profile = '/profile-overview';
  static const String alerts = '/alerts';
  static const String planner = '/planner';

  static String getInitialRoute() => language;
  static String getLanguageRoute() => language;
  static String getHomeRoute() => home;
  static String getRoleRoute() => roleScreen;

  static List<GetPage> routes = [
    GetPage(name: language, page: () => const LanguageScreen()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: roleScreen, page: () => const RoleScreen()),
    GetPage(name: soilType, page: () => const SoilType()),
    GetPage(name: seedType, page: () => const SeedType()),
    GetPage(name: help, page: () => const Help()),
    GetPage(name: cornFacts, page: () => const CornFacts()),
    GetPage(name: toolGuide, page: () => const ToolGuide()),
    GetPage(name: growthConditions, page: () => const GrowthConditions()),
    GetPage(name: wateringInfo, page: () => const WateringInfo()),
    GetPage(name: pestManagement, page: () => const PestManagement()),
    GetPage(name: nursingPlants, page: () => const NursingPlants()),
    GetPage(name: growingPlants, page: () => const GrowingPlants()),
    GetPage(name: floweringPlants, page: () => const FloweringPlants()),
    GetPage(name: ripeCorns, page: () => const RipeCorns()),
    GetPage(name: collectingCorns, page: () => const CollectingCorns()),
    GetPage(name: marketingCorns, page: () => const MarketingCorns()),
    GetPage(name: profile, page: () => const ProfileOverview()),
    GetPage(name: alerts, page: () => const AlertsScreen()),
    GetPage(name: planner, page: () => const PlannerScreen()),
  ];
}
