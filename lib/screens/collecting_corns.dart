import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:get/get.dart'; 

class CollectingCorns extends StatelessWidget {
  const CollectingCorns({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.search_rounded,
        titleKey: 'collect_scouting_title',
        descriptionKey: 'collect_scouting_description',
        highlightKeys: const [
          'collect_scouting_highlight1',
          'collect_scouting_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.schedule_rounded,
        titleKey: 'collect_timing_title',
        descriptionKey: 'collect_timing_description',
        highlightKeys: const [
          'collect_timing_highlight1',
          'collect_timing_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.local_shipping_rounded,
        titleKey: 'collect_transport_title',
        descriptionKey: 'collect_transport_description',
        highlightKeys: const [
          'collect_transport_highlight1',
          'collect_transport_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'collect_timeline_checklist_title',
        detailKey: 'collect_timeline_checklist_detail',
      ),
      CornTimelineItem(
        titleKey: 'collect_timeline_harvest_title',
        detailKey: 'collect_timeline_harvest_detail',
      ),
      CornTimelineItem(
        titleKey: 'collect_timeline_post_title',
        detailKey: 'collect_timeline_post_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'collect_title',
      introKey: 'collect_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'collect_tip_label',
        'collect_tip_hydration',
        'collect_tip_vests',
      ],
      accentIcon: Icons.agriculture,
      resourceKeys: const [
        'collect_resource_cleaning',
        'collect_resource_drying',
        'collect_resource_storage',
      ],
      videoId: 'collect_video_id'.tr,
    );
  }
}
