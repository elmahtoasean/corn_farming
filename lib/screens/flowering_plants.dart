import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:corn_farming/controller/localization_controller.dart';
import 'package:corn_farming/models/language_model.dart';
import 'package:get/get.dart'; 

class FloweringPlants extends StatelessWidget {
  const FloweringPlants({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.filter_vintage,
        titleKey: 'flower_tassel_title',
        descriptionKey: 'flower_tassel_description',
        highlightKeys: const [
          'flower_tassel_highlight1',
          'flower_tassel_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.pest_control,
        titleKey: 'flower_silk_title',
        descriptionKey: 'flower_silk_description',
        highlightKeys: const [
          'flower_silk_highlight1',
          'flower_silk_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.spa,
        titleKey: 'flower_pollination_title',
        descriptionKey: 'flower_pollination_description',
        highlightKeys: const [
          'flower_pollination_highlight1',
          'flower_pollination_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'flower_timeline_pretassel_title',
        detailKey: 'flower_timeline_pretassel_detail',
      ),
      CornTimelineItem(
        titleKey: 'flower_timeline_peak_title',
        detailKey: 'flower_timeline_peak_detail',
      ),
      CornTimelineItem(
        titleKey: 'flower_timeline_post_title',
        detailKey: 'flower_timeline_post_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'flower_title',
      introKey: 'flower_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'flower_tip_record',
        'flower_tip_sprayers',
        'flower_tip_refuges',
      ],
      accentIcon: Icons.filter_vintage,
      resourceKeys: const [
        'flower_resource_pollination',
        'flower_resource_fungal',
        'flower_resource_monitor',
      ],
      videoId: 'flower_video_id'.tr,
    );
  }
}
