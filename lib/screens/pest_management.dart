import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class PestManagement extends StatelessWidget {
  const PestManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.bug_report,
        titleKey: 'pest_scouting_title',
        descriptionKey: 'pest_scouting_description',
        highlightKeys: const [
          'pest_scouting_highlight1',
          'pest_scouting_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.handshake,
        titleKey: 'pest_biological_title',
        descriptionKey: 'pest_biological_description',
        highlightKeys: const [
          'pest_biological_highlight1',
          'pest_biological_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.security,
        titleKey: 'pest_targeted_title',
        descriptionKey: 'pest_targeted_description',
        highlightKeys: const [
          'pest_targeted_highlight1',
          'pest_targeted_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'pest_timeline_preplant_title',
        detailKey: 'pest_timeline_preplant_detail',
      ),
      CornTimelineItem(
        titleKey: 'pest_timeline_early_title',
        detailKey: 'pest_timeline_early_detail',
      ),
      CornTimelineItem(
        titleKey: 'pest_timeline_mid_title',
        detailKey: 'pest_timeline_mid_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'pest_title',
      introKey: 'pest_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'pest_tip_calibrate',
        'pest_tip_records',
        'pest_tip_training',
      ],
      accentIcon: Icons.bug_report,
      resourceKeys: const [
        'pest_resource_scouting',
        'pest_resource_biocontrol',
        'pest_resource_thresholds',
      ],
      videoId: 'pest_video_id'.tr,
    );
  }
}
