import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../places/places.dart';
import '../../profile/presentation/widgets/profile_photo_view.dart';
import '../application/cost_estimator.dart';
import '../application/dates_providers.dart';
import 'date_builder_screen.dart';
import 'widgets/venue_bits.dart';

/// "View place" — full venue detail. Location is shown only as an approximate
/// area (never an exact address/coordinate), with a safety cue and an honest
/// sample-data notice. Actions: save the place, or build a date around it.
class VenueDetailScreen extends ConsumerWidget {
  const VenueDetailScreen({super.key, required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = venue;
    final saved = ref.watch(savedPlacesProvider.select(
        (list) => list.any((x) => x.id == v.id)));
    final cost = CostRange(v.costForTwoMin, v.costForTwoMax);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            // Clear the floating nav bar under the trailing action buttons.
            padding: const EdgeInsets.only(bottom: AppSpacing.navBarClearance),
            children: [
              SizedBox(
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProfilePhotoView(seed: v.imageSeed, showMonogram: false),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xE60A0E17)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      bottom: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.category.label.toUpperCase(),
                              style: AppTypography.label),
                          const SizedBox(height: 2),
                          Text(v.name, style: AppTypography.headingLarge),
                          const SizedBox(height: AppSpacing.sm),
                          SafetyChip(label: v.safety),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SampleDataNotice(),
                    const SizedBox(height: AppSpacing.lg),
                    LiquidGlassCard(
                      child: Column(
                        children: [
                          if (v.rating != null)
                            _Fact(
                              icon: Icons.star_outline,
                              label: 'Rating',
                              child: RatingBadge(
                                  rating: v.rating!, count: v.ratingCount),
                            ),
                          _Fact(
                            icon: Icons.payments_outlined,
                            label: 'Price',
                            value: '${v.priceRange}  ·  ${cost.label}',
                          ),
                          _Fact(
                            icon: Icons.location_on_outlined,
                            label: 'Distance',
                            value: v.distanceKm != null
                                ? '~${approxMinutes(v.distanceKm!)} min · ${v.areaLabel} (approx.)'
                                : '${v.areaLabel} (approx.)',
                          ),
                          if (v.openingHoursLabel != null)
                            _Fact(
                              icon: Icons.schedule,
                              label: 'Hours',
                              value: v.openingHoursLabel!,
                            ),
                          if (v.reservable)
                            _Fact(
                              icon: Icons.event_available_outlined,
                              label: 'Reservations',
                              value: v.reservationNote ?? 'Available',
                            ),
                          _Fact(
                            icon: Icons.shield_outlined,
                            label: 'Safety',
                            value:
                                '${v.safety.label} · exact locations are never shared',
                            last: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    LiquidGlassButton(
                      label: saved ? 'Saved' : 'Save place',
                      icon: saved ? Icons.bookmark : Icons.bookmark_border,
                      variant: GlassButtonVariant.glass,
                      expand: true,
                      onPressed: () => ref
                          .read(savedPlacesProvider.notifier)
                          .toggle(v),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LiquidGlassButton(
                      label: 'Build date',
                      icon: Icons.event_outlined,
                      expand: true,
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (_) => DateBuilderScreen(seedVenue: v)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassIconButton(
                  icon: Icons.arrow_back_ios_new,
                  semanticLabel: 'Back',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.label,
    this.value,
    this.child,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 96,
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Expanded(
            child: child ??
                Text(value ?? '',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
