import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:get/get.dart'; 

class NursingPlants extends StatelessWidget {
  const NursingPlants({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.volunteer_activism,
        titleKey: 'nursing_seedling_title',
        descriptionKey: 'nursing_seedling_description',
        highlightKeys: const [
          'nursing_seedling_highlight1',
          'nursing_seedling_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.health_and_safety,
        titleKey: 'nursing_disease_title',
        descriptionKey: 'nursing_disease_description',
        highlightKeys: const [
          'nursing_disease_highlight1',
          'nursing_disease_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.shield_moon,
        titleKey: 'nursing_stress_title',
        descriptionKey: 'nursing_stress_description',
        highlightKeys: const [
          'nursing_stress_highlight1',
          'nursing_stress_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'nursing_timeline_week1_title',
        detailKey: 'nursing_timeline_week1_detail',
      ),
      CornTimelineItem(
        titleKey: 'nursing_timeline_early_title',
        detailKey: 'nursing_timeline_early_detail',
      ),
      CornTimelineItem(
        titleKey: 'nursing_timeline_mid_title',
        detailKey: 'nursing_timeline_mid_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'nursing_title',
      introKey: 'nursing_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'nursing_tip_training',
        'nursing_tip_photos',
        'nursing_tip_predators',
      ],
      accentIcon: Icons.volunteer_activism,
      resourceKeys: const [
        'nursing_resource_pruning',
        'nursing_resource_mulch',
        'nursing_resource_support',
      ],
      videoId: 'nursing_video_id'.tr,
    );
  }
}
