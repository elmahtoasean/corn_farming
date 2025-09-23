import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class RipeCorns extends StatelessWidget {
  const RipeCorns({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.visibility,
        titleKey: 'ripe_visual_title',
        descriptionKey: 'ripe_visual_description',
        highlightKeys: const [
          'ripe_visual_highlight1',
          'ripe_visual_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.science,
        titleKey: 'ripe_moisture_title',
        descriptionKey: 'ripe_moisture_description',
        highlightKeys: const [
          'ripe_moisture_highlight1',
          'ripe_moisture_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.storage,
        titleKey: 'ripe_harvest_title',
        descriptionKey: 'ripe_harvest_description',
        highlightKeys: const [
          'ripe_harvest_highlight1',
          'ripe_harvest_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'ripe_timeline_checks_title',
        detailKey: 'ripe_timeline_checks_detail',
      ),
      CornTimelineItem(
        titleKey: 'ripe_timeline_harvest_title',
        detailKey: 'ripe_timeline_harvest_detail',
      ),
      CornTimelineItem(
        titleKey: 'ripe_timeline_handling_title',
        detailKey: 'ripe_timeline_handling_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'ripe_title',
      introKey: 'ripe_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'ripe_tip_label',
        'ripe_tip_transport',
        'ripe_tip_logs',
      ],
      accentIcon: Icons.task_alt,
    );
  }
}
