import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.route,
        titleKey: 'planner_mapping_title',
        descriptionKey: 'planner_mapping_description',
        highlightKeys: const [
          'planner_mapping_highlight1',
          'planner_mapping_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.event_note,
        titleKey: 'planner_tasks_title',
        descriptionKey: 'planner_tasks_description',
        highlightKeys: const [
          'planner_tasks_highlight1',
          'planner_tasks_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.attach_money,
        titleKey: 'planner_budget_title',
        descriptionKey: 'planner_budget_description',
        highlightKeys: const [
          'planner_budget_highlight1',
          'planner_budget_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'planner_timeline_pre_title',
        detailKey: 'planner_timeline_pre_detail',
      ),
      CornTimelineItem(
        titleKey: 'planner_timeline_mid_title',
        detailKey: 'planner_timeline_mid_detail',
      ),
      CornTimelineItem(
        titleKey: 'planner_timeline_post_title',
        detailKey: 'planner_timeline_post_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'planner_title',
      introKey: 'planner_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'planner_tip_dashboards',
        'planner_tip_checklist',
        'planner_tip_review',
      ],
      accentIcon: Icons.map,
      resourceKeys: const [
        'planner_resource_templates',
        'planner_resource_risk',
        'planner_resource_team',
      ],
      videoId: 'planner_video_id'.tr,
    );
  }
}
