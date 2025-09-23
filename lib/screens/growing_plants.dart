import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class GrowingPlants extends StatelessWidget {
  const GrowingPlants({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.eco_rounded,
        titleKey: 'growing_stand_title',
        descriptionKey: 'growing_stand_description',
        highlightKeys: const [
          'growing_stand_highlight1',
          'growing_stand_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.yard_rounded,
        titleKey: 'growing_vigor_title',
        descriptionKey: 'growing_vigor_description',
        highlightKeys: const [
          'growing_vigor_highlight1',
          'growing_vigor_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.poll,
        titleKey: 'growing_reproductive_title',
        descriptionKey: 'growing_reproductive_description',
        highlightKeys: const [
          'growing_reproductive_highlight1',
          'growing_reproductive_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'growing_timeline_weeks1_title',
        detailKey: 'growing_timeline_weeks1_detail',
      ),
      CornTimelineItem(
        titleKey: 'growing_timeline_weeks4_title',
        detailKey: 'growing_timeline_weeks4_detail',
      ),
      CornTimelineItem(
        titleKey: 'growing_timeline_weeks7_title',
        detailKey: 'growing_timeline_weeks7_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'growing_title',
      introKey: 'growing_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'growing_tip_rotation',
        'growing_tip_mapping',
        'growing_tip_tracking',
      ],
      accentIcon: Icons.trending_up,
      resourceKeys: const [
        'growing_resource_canopy',
        'growing_resource_fertility',
        'growing_resource_lodging',
      ],
      videoId: 'growing_video_id'.tr,
    );
  }
}
