import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum _AreaUnit { hectare, acre, decimal }

class SeedCalculatorCard extends StatefulWidget {
  const SeedCalculatorCard({super.key});

  @override
  State<SeedCalculatorCard> createState() => _SeedCalculatorCardState();
}

class _SeedCalculatorCardState extends State<SeedCalculatorCard> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _rowSpacingController =
      TextEditingController(text: '75');
  final TextEditingController _plantSpacingController =
      TextEditingController(text: '25');

  _AreaUnit _selectedUnit = _AreaUnit.acre;
  double _areaInSquareMeters = 4046.86; // default 1 acre
  double _emergence = 85;

  @override
  void initState() {
    super.initState();
    _areaController.text = '1';
  }

  @override
  void dispose() {
    _areaController.dispose();
    _rowSpacingController.dispose();
    _plantSpacingController.dispose();
    super.dispose();
  }

  void _onAreaChanged(String value) {
    final parsed = _parseInput(value);
    if (parsed != null && parsed > 0) {
      setState(() {
        _areaInSquareMeters = _toSquareMeters(parsed, _selectedUnit);
      });
    }
  }

  void _onUnitChanged(_AreaUnit? unit) {
    if (unit == null) return;
    setState(() {
      _selectedUnit = unit;
      final converted = _fromSquareMeters(_areaInSquareMeters, unit);
      _areaController.text = _formatDecimal(converted);
    });
  }

  double? _parseInput(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  double _toSquareMeters(double value, _AreaUnit unit) {
    switch (unit) {
      case _AreaUnit.hectare:
        return value * 10000;
      case _AreaUnit.acre:
        return value * 4046.86;
      case _AreaUnit.decimal:
        return value * 40.4686;
    }
  }

  double _fromSquareMeters(double value, _AreaUnit unit) {
    switch (unit) {
      case _AreaUnit.hectare:
        return value / 10000;
      case _AreaUnit.acre:
        return value / 4046.86;
      case _AreaUnit.decimal:
        return value / 40.4686;
    }
  }

  String _formatNumber(num value) {
    final digits = value.round();
    final string = digits.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < string.length; i++) {
      final reverseIndex = string.length - i - 1;
      buffer.write(string[i]);
      if (reverseIndex % 3 == 0 && i != string.length - 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  String _formatDecimal(double value) {
    var formatted = value.toStringAsFixed(value >= 10 ? 1 : 2);
    while (formatted.contains('.') && formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  void _resetForm() {
    setState(() {
      _selectedUnit = _AreaUnit.acre;
      _areaInSquareMeters = 4046.86;
      _areaController.text = '1';
      _rowSpacingController.text = '75';
      _plantSpacingController.text = '25';
      _emergence = 85;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rowSpacing = _parseInput(_rowSpacingController.text) ?? 0;
    final plantSpacing = _parseInput(_plantSpacingController.text) ?? 0;
    final emergenceRate = _emergence.clamp(10, 100) / 100;

    final areaM2 = _areaInSquareMeters;
    final rowSpacingM = rowSpacing / 100;
    final plantSpacingM = plantSpacing / 100;

    double? plants;
    double? seeds;
    double? seedWeightKg;

    if (areaM2 > 0 && rowSpacingM > 0 && plantSpacingM > 0) {
      plants = areaM2 / (rowSpacingM * plantSpacingM);
      seeds = plants / emergenceRate;
      seedWeightKg = seeds * 0.0003;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final fieldWidth = isWide
            ? (constraints.maxWidth - 24) / 2
            : constraints.maxWidth;

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
                    child: Icon(Icons.calculate_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'seed_calc_title'.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'seed_calc_description'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('seed_calc_reset'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'seed_calc_area_label'.tr,
                        helperText: 'seed_calc_area_hint'.tr,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<_AreaUnit>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: _AreaUnit.hectare,
                                child:
                                    Text('seed_calc_area_unit_hectare'.tr),
                              ),
                              DropdownMenuItem(
                                value: _AreaUnit.acre,
                                child: Text('seed_calc_area_unit_acre'.tr),
                              ),
                              DropdownMenuItem(
                                value: _AreaUnit.decimal,
                                child: Text('seed_calc_area_unit_decimal'.tr),
                              ),
                            ],
                            onChanged: _onUnitChanged,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _areaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            decoration: InputDecoration(
                              hintText: 'seed_calc_area_hint'.tr,
                            ),
                            onChanged: _onAreaChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: TextField(
                      controller: _rowSpacingController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'seed_calc_row_spacing'.tr,
                        helperText: 'seed_calc_row_hint'.tr,
                        suffixText: 'cm',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: TextField(
                      controller: _plantSpacingController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'seed_calc_plant_spacing'.tr,
                        helperText: 'seed_calc_plant_hint'.tr,
                        suffixText: 'cm',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'seed_calc_emergence'.trParams({
                  'value': _emergence.toStringAsFixed(0),
                }),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: _emergence,
                min: 60,
                max: 98,
                divisions: 19,
                label: '${_emergence.toStringAsFixed(0)}%',
                onChanged: (value) => setState(() => _emergence = value),
              ),
              const SizedBox(height: 16),
              if (plants != null && seeds != null && seedWeightKg != null)
                _SeedResultSummary(
                  plants: _formatNumber(plants),
                  seeds: _formatNumber(seeds),
                  weightKg: seedWeightKg.toStringAsFixed(2),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'seed_calc_result_empty'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'seed_calc_assumption'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeedResultSummary extends StatelessWidget {
  final String plants;
  final String seeds;
  final String weightKg;

  const _SeedResultSummary({
    required this.plants,
    required this.seeds,
    required this.weightKg,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ResultTile(
          label: 'seed_calc_result_population'.tr,
          value: plants,
          caption: 'seed_calc_result_population_hint'.tr,
        ),
        _ResultTile(
          label: 'seed_calc_result_seeds'.tr,
          value: seeds,
          caption: 'seed_calc_result_seeds_hint'.tr,
        ),
        _ResultTile(
          label: 'seed_calc_result_weight'.tr,
          value: '$weightKg kg',
          caption: 'seed_calc_result_weight_hint'.tr,
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _ResultTile({
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
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
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
