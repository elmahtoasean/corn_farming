import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:get/get.dart'; 

class CornFacts extends StatelessWidget {
  const CornFacts({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.history_edu,
        titleKey: 'facts_origins_title',
        descriptionKey: 'facts_origins_description',
        highlightKeys: const [
          'facts_origins_highlight1',
          'facts_origins_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.eco,
        titleKey: 'facts_uses_title',
        descriptionKey: 'facts_uses_description',
        highlightKeys: const [
          'facts_uses_highlight1',
          'facts_uses_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.public,
        titleKey: 'facts_global_title',
        descriptionKey: 'facts_global_description',
        highlightKeys: const [
          'facts_global_highlight1',
          'facts_global_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'facts_timeline_ancient_title',
        detailKey: 'facts_timeline_ancient_detail',
      ),
      CornTimelineItem(
        titleKey: 'facts_timeline_modern_title',
        detailKey: 'facts_timeline_modern_detail',
      ),
      CornTimelineItem(
        titleKey: 'facts_timeline_future_title',
        detailKey: 'facts_timeline_future_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'facts_title',
      introKey: 'facts_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'facts_tip_museums',
        'facts_tip_heirloom',
        'facts_tip_support',
      ],
      accentIcon: Icons.history,
      resourceKeys: const [
        'facts_resource_nutrition',
        'facts_resource_history',
        'facts_resource_use',
      ],
      videoId: 'facts_video_id'.tr,
    );
  }
}
