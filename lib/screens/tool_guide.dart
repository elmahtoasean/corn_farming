import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class ToolGuide extends StatelessWidget {
  const ToolGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.construction,
        titleKey: 'tool_essential_title',
        descriptionKey: 'tool_essential_description',
        highlightKeys: const [
          'tool_essential_highlight1',
          'tool_essential_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.precision_manufacturing,
        titleKey: 'tool_mechanized_title',
        descriptionKey: 'tool_mechanized_description',
        highlightKeys: const [
          'tool_mechanized_highlight1',
          'tool_mechanized_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.sensors,
        titleKey: 'tool_digital_title',
        descriptionKey: 'tool_digital_description',
        highlightKeys: const [
          'tool_digital_highlight1',
          'tool_digital_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'tool_timeline_pre_title',
        detailKey: 'tool_timeline_pre_detail',
      ),
      CornTimelineItem(
        titleKey: 'tool_timeline_mid_title',
        detailKey: 'tool_timeline_mid_detail',
      ),
      CornTimelineItem(
        titleKey: 'tool_timeline_post_title',
        detailKey: 'tool_timeline_post_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'tool_title',
      introKey: 'tool_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'tool_tip_log',
        'tool_tip_label',
        'tool_tip_training',
      ],
      accentIcon: Icons.handyman,
      resourceKeys: const [
        'tools_resource_maintenance',
        'tools_resource_calibration',
        'tools_resource_safety',
      ],
      videoId: 'tools_video_id'.tr,
    );
  }
}
