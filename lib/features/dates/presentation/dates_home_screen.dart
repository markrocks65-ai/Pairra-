import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../places/places.dart';
import '../application/dates_providers.dart';
import 'create_date_sheet.dart';
import 'date_builder_screen.dart';
import 'date_suggestions_screen.dart';
import 'venue_detail_screen.dart';
import 'widgets/planned_date_card.dart';
import 'widgets/venue_bits.dart';
import 'widgets/venue_date_card.dart';

/// Dates home — the hub that turns a match into a real date. Shows upcoming
/// dates, suggested places (via the places repository + compatibility of
/// tastes), saved places, and past dates. "Create a date" opens the builder
/// flow.
class DatesHomeScreen extends ConsumerWidget {
  const DatesHomeScreen({super.key});

  void _viewPlace(BuildContext context, Venue v) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VenueDetailScreen(venue: v)));

  // The builder is a focused, full-screen flow (form + pinned save), so it goes
  // over the shell rather than being framed by the tab nav.
  void _buildDate(BuildContext context, Venue v) =>
      Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => DateBuilderScreen(seedVenue: v)));

  Future<void> _create(BuildContext context) async {
    final criteria = await showCreateDate(context);
    if (criteria != null && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DateSuggestionsScreen(criteria: criteria)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planned = ref.watch(plannedDatesProvider);
    final upcoming = planned.where((d) => !d.isPast).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final past = planned.where((d) => d.isPast).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final saved = ref.watch(savedPlacesProvider);
    final suggested = ref.watch(suggestedVenuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Dates', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            color: AppColors.accent,
            tooltip: 'Create a date',
            onPressed: () => _create(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg,
              AppSpacing.xl, AppSpacing.navBarClearance),
          children: [
            _Section(
              title: 'Upcoming',
              child: upcoming.isEmpty
                  ? _Hint('No dates planned yet. Create one to get started.')
                  : Column(
                      children: [
                        for (final d in upcoming) ...[
                          PlannedDateCard(
                            date: d,
                            onRemove: () => ref
                                .read(plannedDatesProvider.notifier)
                                .remove(d.id),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
            ),
            _Section(
              title: 'Suggested',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SampleDataNotice(),
                  const SizedBox(height: AppSpacing.md),
                  suggested.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accent),
                      ),
                    ),
                    error: (_, _) =>
                        _Hint('Couldn\'t load suggestions right now.'),
                    data: (venues) => Column(
                      children: [
                        for (final v in venues.take(4)) ...[
                          VenueDateCard(
                            venue: v,
                            onViewPlace: () => _viewPlace(context, v),
                            onBuildDate: () => _buildDate(context, v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Saved places',
              child: saved.isEmpty
                  ? _Hint('Save places you like to plan a date later.')
                  : Column(
                      children: [
                        for (final v in saved) ...[
                          VenueDateCard(
                            venue: v,
                            onViewPlace: () => _viewPlace(context, v),
                            onBuildDate: () => _buildDate(context, v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
            ),
            if (past.isNotEmpty)
              _Section(
                title: 'Past dates',
                child: Column(
                  children: [
                    for (final d in past) ...[
                      PlannedDateCard(date: d),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
            child: Text(title, style: AppTypography.headingMedium),
          ),
          child,
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      child: Text(text, style: AppTypography.bodySecondary),
    );
  }
}
