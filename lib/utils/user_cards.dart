import 'package:corn_farming/utils/app_route.dart';

List<Map<String, dynamic>> getCards(String? role) {
  List<Map<String, dynamic>> cards = [];
  cards.addAll([
    {
      'title': 'soil_type',
      'icon': 'assets/images/identify-soil-type.jpg',
      'route': RouteHelper.soilType,
    },
    {
      'title': 'growth_conditions',
      'icon': 'assets/images/growth_conditions.png',
      'route': RouteHelper.growthConditions,
    },
    {
      'title': 'seed_type',
      'icon': 'assets/images/seed_type.jpg',
      'route': RouteHelper.seedType,
    },
    {
      'title': 'watering',
      'icon': 'assets/images/watering.jpg',
      'route': RouteHelper.wateringInfo,
    },
    {
      'title': 'pest',
      'icon': 'assets/images/pest.jpg',
      'route': RouteHelper.pestManagement,
    },
    {
      'title': 'nursing',
      'icon': 'assets/images/nursing.jpg',
      'route': RouteHelper.nursingPlants,
    },
    {
      'title': 'grow',
      'icon': 'assets/images/grow.jpg',
      'route': RouteHelper.growingPlants,
    },
    {
      'title': 'flower',
      'icon': 'assets/images/flower.jpg',
      'route': RouteHelper.floweringPlants,
    },
    {
      'title': 'ripe',
      'icon': 'assets/images/ripe.jpg',
      'route': RouteHelper.ripeCorns,
    },
    {
      'title': 'fruit_collect',
      'icon': 'assets/images/collecting.jpg',
      'route': RouteHelper.collectingCorns,
    },
    {
      'title': 'market',
      'icon': 'assets/images/marketing.jpg',
      'route': RouteHelper.marketingCorns,
    }
  ]);
  if (role == 'general_user') {
    cards.addAll([
      {
        'title': 'corn_facts',
        'icon': 'assets/images/facts.jpg',
        'route': RouteHelper.cornFacts,
      }
    ]);
  }

  if (role == 'farmer') {
    cards.addAll([
      {
        'title': 'tool_guide',
        'icon': 'assets/images/tools.jpg',
        'route': RouteHelper.toolGuide,
      }
    ]);
  }
  return cards;
}
