import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class GrowthConditions extends StatelessWidget {
  const GrowthConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.light_mode_rounded,
        titleKey: 'growth_sunlight_title',
        descriptionKey: 'growth_sunlight_description',
        highlightKeys: const [
          'growth_sunlight_highlight1',
          'growth_sunlight_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.water_drop,
        titleKey: 'growth_moisture_title',
        descriptionKey: 'growth_moisture_description',
        highlightKeys: const [
          'growth_moisture_highlight1',
          'growth_moisture_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.bolt,
        titleKey: 'growth_nutrient_title',
        descriptionKey: 'growth_nutrient_description',
        highlightKeys: const [
          'growth_nutrient_highlight1',
          'growth_nutrient_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'growth_timeline_emergence_title',
        detailKey: 'growth_timeline_emergence_detail',
      ),
      CornTimelineItem(
        titleKey: 'growth_timeline_vegetative_title',
        detailKey: 'growth_timeline_vegetative_detail',
      ),
      CornTimelineItem(
        titleKey: 'growth_timeline_reproductive_title',
        detailKey: 'growth_timeline_reproductive_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'growth_conditions_title',
      introKey: 'growth_conditions_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'growth_tip_weather',
        'growth_tip_rotation',
        'growth_tip_windbreak',
      ],
      accentIcon: Icons.sunny,
    );
  }
}
