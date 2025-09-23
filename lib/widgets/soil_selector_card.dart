import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SoilSelectorCard extends StatefulWidget {
  const SoilSelectorCard({super.key});

  @override
  State<SoilSelectorCard> createState() => _SoilSelectorCardState();
}

class _SoilOption {
  final String value;
  final String nameKey;
  final String summaryKey;
  final String ratingKey;
  final String managementKey;
  final String cropKey;

  const _SoilOption({
    required this.value,
    required this.nameKey,
    required this.summaryKey,
    required this.ratingKey,
    required this.managementKey,
    required this.cropKey,
  });
}

class _SoilSelectorCardState extends State<SoilSelectorCard> {
  static const List<_SoilOption> _options = [
    _SoilOption(
      value: 'loam',
      nameKey: 'soil_selector_loam_name',
      summaryKey: 'soil_selector_loam_summary',
      ratingKey: 'soil_selector_loam_rating',
      managementKey: 'soil_selector_loam_management',
      cropKey: 'soil_selector_loam_crops',
    ),
    _SoilOption(
      value: 'sandy',
      nameKey: 'soil_selector_sandy_name',
      summaryKey: 'soil_selector_sandy_summary',
      ratingKey: 'soil_selector_sandy_rating',
      managementKey: 'soil_selector_sandy_management',
      cropKey: 'soil_selector_sandy_crops',
    ),
    _SoilOption(
      value: 'silty',
      nameKey: 'soil_selector_silty_name',
      summaryKey: 'soil_selector_silty_summary',
      ratingKey: 'soil_selector_silty_rating',
      managementKey: 'soil_selector_silty_management',
      cropKey: 'soil_selector_silty_crops',
    ),
    _SoilOption(
      value: 'clay',
      nameKey: 'soil_selector_clay_name',
      summaryKey: 'soil_selector_clay_summary',
      ratingKey: 'soil_selector_clay_rating',
      managementKey: 'soil_selector_clay_management',
      cropKey: 'soil_selector_clay_crops',
    ),
  ];

  _SoilOption _selectedOption = _options.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.terrain_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'soil_selector_title'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'soil_selector_description'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'soil_selector_label'.tr,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<_SoilOption>(
            value: _selectedOption,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: _options
                .map(
                  (option) => DropdownMenuItem<_SoilOption>(
                    value: option,
                    child: Text(option.nameKey.tr),
                  ),
                )
                .toList(),
            onChanged: (option) {
              if (option != null) {
                setState(() => _selectedOption = option);
              }
            },
          ),
          const SizedBox(height: 20),
          _SoilInsight(option: _selectedOption),
        ],
      ),
    );
  }
}

class _SoilInsight extends StatelessWidget {
  final _SoilOption option;

  const _SoilInsight({required this.option});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.nameKey.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            option.summaryKey.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.star_rate_rounded, size: 18),
                label: Text(option.ratingKey.tr),
                backgroundColor:
                    theme.colorScheme.onPrimary.withOpacity(0.12),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InsightTile(
            icon: Icons.engineering_rounded,
            title: 'soil_selector_management_label'.tr,
            description: option.managementKey.tr,
          ),
          const SizedBox(height: 12),
          _InsightTile(
            icon: Icons.local_florist_rounded,
            title: 'soil_selector_crop_label'.tr,
            description: option.cropKey.tr,
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InsightTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
