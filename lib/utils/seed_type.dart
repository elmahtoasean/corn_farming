import 'package:corn_farming/utils/detail_page.dart';
import 'package:corn_farming/widgets/seed_calculator_card.dart';
import 'package:flutter/material.dart';

class SeedType extends StatelessWidget {
  const SeedType({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      CornDetailSection(
        icon: Icons.biotech_rounded,
        titleKey: 'seed_hybrid_title',
        descriptionKey: 'seed_hybrid_description',
        highlightKeys: const [
          'seed_hybrid_highlight1',
          'seed_hybrid_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.eco_rounded,
        titleKey: 'seed_open_pollinated_title',
        descriptionKey: 'seed_open_pollinated_description',
        highlightKeys: const [
          'seed_open_pollinated_highlight1',
          'seed_open_pollinated_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.inventory_2_rounded,
        titleKey: 'seed_storage_title',
        descriptionKey: 'seed_storage_description',
        highlightKeys: const [
          'seed_storage_highlight1',
          'seed_storage_highlight2',
        ],
      ),
      CornDetailSection(
        icon: Icons.category_rounded,
        titleKey: 'seed_classification_title',
        descriptionKey: 'seed_classification_description',
        highlightKeys: const [
          'seed_classification_hybrid',
          'seed_classification_composite',
          'seed_classification_specialty',
        ],
      ),
    ];

    final timeline = [
      CornTimelineItem(
        titleKey: 'seed_timeline_preseason_title',
        detailKey: 'seed_timeline_preseason_detail',
      ),
      CornTimelineItem(
        titleKey: 'seed_timeline_procurement_title',
        detailKey: 'seed_timeline_procurement_detail',
      ),
      CornTimelineItem(
        titleKey: 'seed_timeline_treatment_title',
        detailKey: 'seed_timeline_treatment_detail',
      ),
    ];

    return CornDetailPage(
      titleKey: 'seed_type_title',
      introKey: 'seed_type_intro',
      sections: sections,
      timeline: timeline,
      quickTipKeys: const [
        'seed_tip_certified',
        'seed_tip_treated',
        'seed_tip_spacing',
      ],
      accentIcon: Icons.spa_rounded,
      resourceKeys: const [
        'seed_resource_certified',
        'seed_resource_inventory',
        'seed_resource_emergence',
      ],
      videoId: 'seed_video_id'.tr,
      supplementalBuilders: [
        (context, width) => Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width > 840 ? 720 : width,
                ),
                child: const SeedCalculatorCard(),
              ),
            ),
      ],
      additionalNarrationKeys: const [
        'seed_calc_narration',
        'seed_classification_narration',
      ],
    );
  }
}
