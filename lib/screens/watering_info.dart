import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class WateringInfo extends StatelessWidget {
  const WateringInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.water_drop,
        titleKey: 'water_establishment_title',
        descriptionKey: 'water_establishment_description',
        highlightKeys: const [
          'water_establishment_highlight1',
          'water_establishment_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.grain,
        titleKey: 'water_critical_title',
        descriptionKey: 'water_critical_description',
        highlightKeys: const [
          'water_critical_highlight1',
          'water_critical_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.waves,
        titleKey: 'water_late_title',
        descriptionKey: 'water_late_description',
        highlightKeys: const [
          'water_late_highlight1',
          'water_late_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'water_timeline_seedling_title',
        detailKey: 'water_timeline_seedling_detail',
      ),
      CornTimelineItem(
        titleKey: 'water_timeline_vegetative_title',
        detailKey: 'water_timeline_vegetative_detail',
      ),
      CornTimelineItem(
        titleKey: 'water_timeline_reproductive_title',
        detailKey: 'water_timeline_reproductive_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'water_title',
      introKey: 'water_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'water_tip_calibrate',
        'water_tip_mulch',
        'water_tip_record',
      ],
      accentIcon: Icons.water_drop,
    );
  }
}
