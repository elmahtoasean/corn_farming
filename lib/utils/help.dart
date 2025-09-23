import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:get/get.dart'; 

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.support_agent,
        titleKey: 'support_contact_title',
        descriptionKey: 'support_contact_description',
        highlightKeys: const [
          'support_contact_highlight1',
          'support_contact_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.school,
        titleKey: 'support_training_title',
        descriptionKey: 'support_training_description',
        highlightKeys: const [
          'support_training_highlight1',
          'support_training_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.groups,
        titleKey: 'support_market_title',
        descriptionKey: 'support_market_description',
        highlightKeys: const [
          'support_market_highlight1',
          'support_market_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'support_timeline_weekly_title',
        detailKey: 'support_timeline_weekly_detail',
      ),
      CornTimelineItem(
        titleKey: 'support_timeline_monthly_title',
        detailKey: 'support_timeline_monthly_detail',
      ),
      CornTimelineItem(
        titleKey: 'support_timeline_harvest_title',
        detailKey: 'support_timeline_harvest_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'support_title',
      introKey: 'support_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'support_tip_hotline',
        'support_tip_forum',
        'support_tip_updates',
      ],
      accentIcon: Icons.support_agent,
      resourceKeys: const [
        'support_resource_directory',
        'support_resource_extension',
        'support_resource_finance',
      ],
      videoId: 'support_video_id'.tr,
    );
  }
}
