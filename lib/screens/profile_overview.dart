import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class ProfileOverview extends StatelessWidget {
  const ProfileOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.person_pin_circle,
        titleKey: 'profile_field_title',
        descriptionKey: 'profile_field_description',
        highlightKeys: const [
          'profile_field_highlight1',
          'profile_field_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.flag_circle,
        titleKey: 'profile_goals_title',
        descriptionKey: 'profile_goals_description',
        highlightKeys: const [
          'profile_goals_highlight1',
          'profile_goals_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.group_work,
        titleKey: 'profile_team_title',
        descriptionKey: 'profile_team_description',
        highlightKeys: const [
          'profile_team_highlight1',
          'profile_team_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'profile_timeline_setup_title',
        detailKey: 'profile_timeline_setup_detail',
      ),
      CornTimelineItem(
        titleKey: 'profile_timeline_midseason_title',
        detailKey: 'profile_timeline_midseason_detail',
      ),
      CornTimelineItem(
        titleKey: 'profile_timeline_close_title',
        detailKey: 'profile_timeline_close_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'profile_title',
      introKey: 'profile_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'profile_tip_roles',
        'profile_tip_reports',
        'profile_tip_backup',
      ],
      accentIcon: Icons.person,
      resourceKeys: const [
        'profile_resource_records',
        'profile_resource_weather',
        'profile_resource_sharing',
      ],
      videoId: 'profile_video_id'.tr,
    );
  }
}
