import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:get/get.dart'; 

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.cloud_queue,
        titleKey: 'alerts_weather_title',
        descriptionKey: 'alerts_weather_description',
        highlightKeys: const [
          'alerts_weather_highlight1',
          'alerts_weather_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.bug_report_outlined,
        titleKey: 'alerts_pest_title',
        descriptionKey: 'alerts_pest_description',
        highlightKeys: const [
          'alerts_pest_highlight1',
          'alerts_pest_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.analytics_outlined,
        titleKey: 'alerts_market_title',
        descriptionKey: 'alerts_market_description',
        highlightKeys: const [
          'alerts_market_highlight1',
          'alerts_market_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'alerts_timeline_daily_title',
        detailKey: 'alerts_timeline_daily_detail',
      ),
      CornTimelineItem(
        titleKey: 'alerts_timeline_weekly_title',
        detailKey: 'alerts_timeline_weekly_detail',
      ),
      CornTimelineItem(
        titleKey: 'alerts_timeline_harvest_title',
        detailKey: 'alerts_timeline_harvest_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'alerts_title',
      introKey: 'alerts_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'alerts_tip_sources',
        'alerts_tip_threshold',
        'alerts_tip_backup',
      ],
      accentIcon: Icons.notifications_active,
      resourceKeys: const [
        'alerts_resource_weather',
        'alerts_resource_extension',
        'alerts_resource_response',
      ],
      videoId: 'alerts_video_id'.tr, // Ensure 'get' package is imported for 'tr'
    );
  }
}
