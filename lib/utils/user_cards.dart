import 'package:corn_farming/utils/app_route.dart';

List<Map<String, dynamic>> getCards(String? role) {
  List<Map<String, dynamic>> cards = [];
  cards.addAll([
    {
      'title': 'soil_type',
      'icon': 'grass',
      'route': RouteHelper.soilType,
      'color': 0xFF8BC34A,
      'summary': 'home_card_soil_summary',
    },
    {
      'title': 'growth_conditions',
      'icon': 'wb_sunny',
      'route': RouteHelper.growthConditions,
      'color': 0xFFFFB300,
      'summary': 'home_card_growth_summary',
    },
    {
      'title': 'seed_type',
      'icon': 'spa',
      'route': RouteHelper.seedType,
      'color': 0xFF4CAF50,
      'summary': 'home_card_seed_summary',
    },
    {
      'title': 'watering',
      'icon': 'water_drop',
      'route': RouteHelper.wateringInfo,
      'color': 0xFF29B6F6,
      'summary': 'home_card_water_summary',
    },
    {
      'title': 'pest',
      'icon': 'bug_report',
      'route': RouteHelper.pestManagement,
      'color': 0xFFD32F2F,
      'summary': 'home_card_pest_summary',
    },
    {
      'title': 'nursing',
      'icon': 'volunteer_activism',
      'route': RouteHelper.nursingPlants,
      'color': 0xFF8E24AA,
      'summary': 'home_card_nursing_summary',
    },
    {
      'title': 'grow',
      'icon': 'auto_graph',
      'route': RouteHelper.growingPlants,
      'color': 0xFF5C6BC0,
      'summary': 'home_card_growing_summary',
    },
    {
      'title': 'flower',
      'icon': 'yard',
      'route': RouteHelper.floweringPlants,
      'color': 0xFFFF7043,
      'summary': 'home_card_flowering_summary',
    },
    {
      'title': 'ripe',
      'icon': 'emoji_nature',
      'route': RouteHelper.ripeCorns,
      'color': 0xFFFFCA28,
      'summary': 'home_card_ripe_summary',
    },
    {
      'title': 'fruit_collect',
      'icon': 'agriculture',
      'route': RouteHelper.collectingCorns,
      'color': 0xFF6D4C41,
      'summary': 'home_card_collect_summary',
    },
    {
      'title': 'market',
      'icon': 'storefront',
      'route': RouteHelper.marketingCorns,
      'color': 0xFF00796B,
      'summary': 'home_card_market_summary',
    }
  ]);
  if (role == 'general_user') {
    cards.addAll([
      {
        'title': 'corn_facts',
        'icon': 'lightbulb',
        'route': RouteHelper.cornFacts,
        'color': 0xFFFFD54F,
        'summary': 'home_card_facts_summary',
      }
    ]);
  }

  if (role == 'farmer') {
    cards.addAll([
      {
        'title': 'tool_guide',
        'icon': 'construction',
        'route': RouteHelper.toolGuide,
        'color': 0xFF795548,
        'summary': 'home_card_tools_summary',
      }
    ]);
  }
  return cards;
}
