import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ThreatCategory { pest, disease }

class PestDiseaseAdvisorCard extends StatefulWidget {
  const PestDiseaseAdvisorCard({super.key});

  @override
  State<PestDiseaseAdvisorCard> createState() => _PestDiseaseAdvisorCardState();
}

class _ThreatInfo {
  final String nameKey;
  final String impactKey;
  final String symptomKey;
  final String treatmentKey;

  const _ThreatInfo({
    required this.nameKey,
    required this.impactKey,
    required this.symptomKey,
    required this.treatmentKey,
  });
}

class _PestDiseaseAdvisorCardState extends State<PestDiseaseAdvisorCard> {
  ThreatCategory _category = ThreatCategory.pest;

  final Map<ThreatCategory, List<_ThreatInfo>> _threatMap = {
    ThreatCategory.pest: const [
      _ThreatInfo(
        nameKey: 'pest_advisor_fall_armyworm_name',
        impactKey: 'pest_advisor_fall_armyworm_impact',
        symptomKey: 'pest_advisor_fall_armyworm_symptom',
        treatmentKey: 'pest_advisor_fall_armyworm_control',
      ),
      _ThreatInfo(
        nameKey: 'pest_advisor_corn_borer_name',
        impactKey: 'pest_advisor_corn_borer_impact',
        symptomKey: 'pest_advisor_corn_borer_symptom',
        treatmentKey: 'pest_advisor_corn_borer_control',
      ),
      _ThreatInfo(
        nameKey: 'pest_advisor_cutworm_name',
        impactKey: 'pest_advisor_cutworm_impact',
        symptomKey: 'pest_advisor_cutworm_symptom',
        treatmentKey: 'pest_advisor_cutworm_control',
      ),
      _ThreatInfo(
        nameKey: 'pest_advisor_aphid_name',
        impactKey: 'pest_advisor_aphid_impact',
        symptomKey: 'pest_advisor_aphid_symptom',
        treatmentKey: 'pest_advisor_aphid_control',
      ),
    ],
    ThreatCategory.disease: const [
      _ThreatInfo(
        nameKey: 'disease_advisor_blight_name',
        impactKey: 'disease_advisor_blight_impact',
        symptomKey: 'disease_advisor_blight_symptom',
        treatmentKey: 'disease_advisor_blight_control',
      ),
      _ThreatInfo(
        nameKey: 'disease_advisor_downy_mildew_name',
        impactKey: 'disease_advisor_downy_mildew_impact',
        symptomKey: 'disease_advisor_downy_mildew_symptom',
        treatmentKey: 'disease_advisor_downy_mildew_control',
      ),
      _ThreatInfo(
        nameKey: 'disease_advisor_rust_name',
        impactKey: 'disease_advisor_rust_impact',
        symptomKey: 'disease_advisor_rust_symptom',
        treatmentKey: 'disease_advisor_rust_control',
      ),
      _ThreatInfo(
        nameKey: 'disease_advisor_leaf_spot_name',
        impactKey: 'disease_advisor_leaf_spot_impact',
        symptomKey: 'disease_advisor_leaf_spot_symptom',
        treatmentKey: 'disease_advisor_leaf_spot_control',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final threats = _threatMap[_category] ?? const [];

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
                child: Icon(Icons.warning_amber_rounded,
                    color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pest_advisor_title'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'pest_advisor_description'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<ThreatCategory>(
            segments: [
              ButtonSegment(
                value: ThreatCategory.pest,
                label: Text('pest_advisor_toggle_pests'.tr),
                icon: const Icon(Icons.bug_report_rounded),
              ),
              ButtonSegment(
                value: ThreatCategory.disease,
                label: Text('pest_advisor_toggle_diseases'.tr),
                icon: const Icon(Icons.vaccines_rounded),
              ),
            ],
            selected: <ThreatCategory>{_category},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                setState(() => _category = selection.first);
              }
            },
          ),
          const SizedBox(height: 20),
          Column(
            children: threats
                .map((threat) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ThreatTile(info: threat),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ThreatTile extends StatelessWidget {
  final _ThreatInfo info;

  const _ThreatTile({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          info.nameKey.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        subtitle: Text(
          info.impactKey.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary.withOpacity(0.9),
          ),
        ),
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.primary,
        children: [
          _ThreatDetailRow(
            icon: Icons.pest_control_rodent,
            label: 'pest_advisor_symptom_label'.tr,
            description: info.symptomKey.tr,
          ),
          const SizedBox(height: 12),
          _ThreatDetailRow(
            icon: Icons.medical_services_rounded,
            label: 'pest_advisor_control_label'.tr,
            description: info.treatmentKey.tr,
          ),
        ],
      ),
    );
  }
}

class _ThreatDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const _ThreatDetailRow({
    required this.icon,
    required this.label,
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
                label,
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
