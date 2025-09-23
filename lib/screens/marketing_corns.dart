import 'package:corn_farming/utils/detail_page.dart';
import 'package:flutter/material.dart';

class MarketingCorns extends StatelessWidget {
  const MarketingCorns({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.storefront,
        titleKey: 'market_research_title',
        descriptionKey: 'market_research_description',
        highlightKeys: const [
          'market_research_highlight1',
          'market_research_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.branding_watermark,
        titleKey: 'market_branding_title',
        descriptionKey: 'market_branding_description',
        highlightKeys: const [
          'market_branding_highlight1',
          'market_branding_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.delivery_dining,
        titleKey: 'market_distribution_title',
        descriptionKey: 'market_distribution_description',
        highlightKeys: const [
          'market_distribution_highlight1',
          'market_distribution_highlight2',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'market_timeline_pre_title',
        detailKey: 'market_timeline_pre_detail',
      ),
      CornTimelineItem(
        titleKey: 'market_timeline_harvest_title',
        detailKey: 'market_timeline_harvest_detail',
      ),
      CornTimelineItem(
        titleKey: 'market_timeline_post_title',
        detailKey: 'market_timeline_post_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'market_title',
      introKey: 'market_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'market_tip_agreements',
        'market_tip_expenses',
        'market_tip_updates',
      ],
      accentIcon: Icons.storefront,
      resourceKeys: const [
        'market_resource_contracts',
        'market_resource_quality',
        'market_resource_network',
      ],
      videoId: 'market_video_id'.tr,
    );
  }
}
