import 'package:flutter/material.dart';

import '../models/detected_indicator.dart';
import '../theme/app_theme.dart';

class IndicatorChip extends StatelessWidget {
  const IndicatorChip({super.key, required this.indicator});

  final DetectedIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final color = switch (indicator.severity) {
      IndicatorSeverity.high => AppTheme.highRisk,
      IndicatorSeverity.medium => AppTheme.suspicious,
      IndicatorSeverity.low => AppTheme.accent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.42)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 15, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${indicator.title} +${indicator.points}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
