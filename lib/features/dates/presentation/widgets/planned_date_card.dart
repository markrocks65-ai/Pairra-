import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../application/cost_estimator.dart';
import '../../domain/planned_date.dart';

/// A card for a planned date (upcoming or past): when, title, a short itinerary
/// summary, and the estimated cost range.
class PlannedDateCard extends StatelessWidget {
  const PlannedDateCard({
    super.key,
    required this.date,
    this.onTap,
    this.onRemove,
  });

  final PlannedDate date;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  String get _whenLabel {
    final d = date.dateTime;
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    final h24 = d.hour;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final time = '$h:$m ${h24 < 12 ? 'AM' : 'PM'}';
    if (isToday) return 'TONIGHT · $time';
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return '${days[d.weekday - 1]} ${d.month}/${d.day} · $time';
  }

  @override
  Widget build(BuildContext context) {
    final stops = date.itinerary.map((s) => s.title).take(3).join(' · ');
    final cost = CostRange(date.costMin, date.costMax);

    return LiquidGlassCard(
      level: date.isPast ? GlassLevel.subtle : GlassLevel.standard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(_whenLabel, style: AppTypography.label)),
              if (onRemove != null)
                PressableScale(
                  pressedScale: 0.9,
                  onTap: onRemove,
                  child: const Icon(Icons.close,
                      size: 18, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(date.title, style: AppTypography.headingSmall),
          if (stops.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(stops,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(cost.label,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
