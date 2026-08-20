import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../places/places.dart';
import '../application/cost_estimator.dart';
import '../application/dates_providers.dart';
import '../domain/planned_date.dart';

/// Build a date itinerary — a sequence of timed stops (Dinner → Walk →
/// Dessert), with a live total cost range. Optionally seeded from a venue.
class DateBuilderScreen extends ConsumerStatefulWidget {
  const DateBuilderScreen({super.key, this.seedVenue, this.otherName});

  final Venue? seedVenue;
  final String? otherName;

  @override
  ConsumerState<DateBuilderScreen> createState() => _DateBuilderScreenState();
}

class _DateBuilderScreenState extends ConsumerState<DateBuilderScreen> {
  late final TextEditingController _title;
  late DateTime _when;
  late List<ItineraryStop> _stops;

  static const _presets = <(String, int, int)>[
    ('Dinner', 30, 60),
    ('Drinks', 20, 45),
    ('Coffee', 8, 18),
    ('Dessert', 12, 28),
    ('Walk', 0, 0),
    ('Activity', 20, 45),
    ('Movie', 24, 40),
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.seedVenue;
    _title = TextEditingController(
        text: v != null ? 'Date at ${v.name}' : 'Our date');
    final now = DateTime.now();
    _when = DateTime(now.year, now.month, now.day, 19);
    _stops = [
      if (v != null)
        ItineraryStop(
          time: 19 * 60,
          title: _titleForCategory(v.category),
          venueId: v.id,
          venueName: v.name,
          costMin: v.costForTwoMin,
          costMax: v.costForTwoMax,
        ),
    ];
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  static String _titleForCategory(VenueCategory c) => switch (c) {
        VenueCategory.restaurant => 'Dinner',
        VenueCategory.coffee => 'Coffee',
        VenueCategory.nightlife => 'Drinks',
        VenueCategory.park => 'Walk',
        VenueCategory.movie => 'Movie',
        _ => c.label,
      };

  List<ItineraryStop> get _sorted =>
      [..._stops]..sort((a, b) => a.time.compareTo(b.time));

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _darkPicker,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _when.hour, minute: _when.minute),
      builder: _darkPicker,
    );
    if (!mounted) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time?.hour ?? _when.hour,
          time?.minute ?? _when.minute);
    });
  }

  Future<void> _addStop() async {
    await LiquidGlassBottomSheet.show(
      context,
      title: 'Add a stop',
      builder: (context) => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final preset in _presets)
            LiquidGlassChip(
              label: preset.$1,
              onTap: () => Navigator.of(context).pop(preset),
            ),
        ],
      ),
    ).then((selected) async {
      if (selected is! (String, int, int) || !mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 20, minute: 0),
        builder: _darkPicker,
      );
      if (time == null || !mounted) return;
      setState(() {
        _stops.add(ItineraryStop(
          time: time.hour * 60 + time.minute,
          title: selected.$1,
          costMin: selected.$2,
          costMax: selected.$3,
        ));
      });
    });
  }

  void _save() {
    final stops = _sorted;
    final cost = CostEstimator.forItinerary(stops);
    ref.read(plannedDatesProvider.notifier).add(PlannedDate(
          id: 'date_${DateTime.now().microsecondsSinceEpoch}',
          title: _title.text.trim().isEmpty ? 'Our date' : _title.text.trim(),
          dateTime: _when,
          itinerary: stops,
          costMin: cost.min,
          costMax: cost.max,
          createdAt: DateTime.now(),
          otherName: widget.otherName,
        ));
    LiquidGlassOverlay.show(
      context,
      title: 'Date saved',
      message: 'It\'s in your upcoming dates.',
      icon: Icons.event_available,
      tone: OverlayTone.success,
    );
    Navigator.of(context).maybePop();
  }

  static Widget _darkPicker(BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surfaceElevated,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      );

  @override
  Widget build(BuildContext context) {
    final stops = _sorted;
    final cost = CostEstimator.forItinerary(stops);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Build date', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  LiquidGlassTextField(
                    controller: _title,
                    label: 'Title',
                    hint: 'Name your date',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PressableScale(
                    onTap: _pickWhen,
                    child: LiquidGlassSurface(
                      level: GlassLevel.subtle,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      showShadow: false,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          const Icon(Icons.event,
                              size: 20, color: AppColors.textMuted),
                          const SizedBox(width: AppSpacing.md),
                          Text(_whenLabel(_when),
                              style: AppTypography.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('ITINERARY', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.md),
                  if (stops.isEmpty)
                    Text('Add a few stops to build your evening.',
                        style: AppTypography.bodySecondary),
                  for (final stop in stops) _StopRow(
                    stop: stop,
                    onRemove: () => setState(() => _stops.remove(stop)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LiquidGlassButton(
                    label: 'Add stop',
                    icon: Icons.add,
                    variant: GlassButtonVariant.glass,
                    expand: true,
                    onPressed: _addStop,
                  ),
                ],
              ),
            ),
            _Footer(cost: cost, onSave: stops.isEmpty ? null : _save),
          ],
        ),
      ),
    );
  }

  String _whenLabel(DateTime d) {
    final h24 = d.hour;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day}  ·  $h:$m ${h24 < 12 ? 'AM' : 'PM'}';
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.onRemove});
  final ItineraryStop stop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cost = CostRange(stop.costMin, stop.costMax);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(stop.timeLabel,
                style: AppTypography.number.copyWith(fontSize: 14)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.title, style: AppTypography.bodyLarge),
                if (!cost.isFree)
                  Text(cost.shortLabel, style: AppTypography.caption),
              ],
            ),
          ),
          PressableScale(
            pressedScale: 0.9,
            onTap: onRemove,
            child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.cost, required this.onSave});
  final CostRange cost;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl,
          MediaQuery.of(context).padding.bottom + AppSpacing.lg),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estimated total', style: AppTypography.caption),
              Text(cost.label, style: AppTypography.headingSmall),
            ],
          ),
          const Spacer(),
          LiquidGlassButton(label: 'Save date', onPressed: onSave),
        ],
      ),
    );
  }
}
