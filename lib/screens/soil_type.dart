import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class SoilType extends StatelessWidget {
  const SoilType({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.grass,
        titleKey: 'soil_loamy_title',
        descriptionKey: 'soil_loamy_description',
        highlightKeys: const [
          'soil_loamy_highlight1',
          'soil_loamy_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.waves,
        titleKey: 'soil_sandy_title',
        descriptionKey: 'soil_sandy_description',
        highlightKeys: const [
          'soil_sandy_highlight1',
          'soil_sandy_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.layers,
        titleKey: 'soil_clay_title',
        descriptionKey: 'soil_clay_description',
        highlightKeys: const [
          'soil_clay_highlight1',
          'soil_clay_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'soil_timeline_test_title',
        detailKey: 'soil_timeline_test_detail',
      ),
      CornTimelineItem(
        titleKey: 'soil_timeline_till_title',
        detailKey: 'soil_timeline_till_detail',
      ),
      CornTimelineItem(
        titleKey: 'soil_timeline_hydration_title',
        detailKey: 'soil_timeline_hydration_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'soil_preparation_title',
      introKey: 'soil_preparation_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'soil_tip_structure',
        'soil_tip_legumes',
        'soil_tip_mulch',
      ],
      accentIcon: Icons.grass,
    );
  }
}
