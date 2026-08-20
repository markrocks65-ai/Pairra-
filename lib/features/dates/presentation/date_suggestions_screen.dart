import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../places/places.dart';
import '../domain/date_criteria.dart';
import 'date_builder_screen.dart';
import 'venue_detail_screen.dart';
import 'widgets/venue_bits.dart';
import 'widgets/venue_date_card.dart';

/// Venue suggestions for a set of [DateCriteria]. Fetches once from the places
/// repository (sample data for now) and shows date cards.
class DateSuggestionsScreen extends ConsumerStatefulWidget {
  const DateSuggestionsScreen({super.key, required this.criteria});

  final DateCriteria criteria;

  @override
  ConsumerState<DateSuggestionsScreen> createState() =>
      _DateSuggestionsScreenState();
}

class _DateSuggestionsScreenState extends ConsumerState<DateSuggestionsScreen> {
  late Future<List<Venue>> _future =
      ref.read(placesServiceProvider).search(widget.criteria.toPlacesQuery());

  void _viewPlace(Venue v) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VenueDetailScreen(venue: v)));

  // Full-screen over the shell — the builder is a focused flow.
  void _buildDate(Venue v) => Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => DateBuilderScreen(seedVenue: v)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Suggested places', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<Venue>>(
          future: _future,
          builder: (context, snapshot) {
            // Failure (e.g. no internet / provider error) — don't spin forever.
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined,
                          size: 40, color: AppColors.textMuted),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Couldn\'t load places right now. Check your connection '
                        'and try again.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySecondary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LiquidGlassButton(
                        label: 'Retry',
                        variant: GlassButtonVariant.glass,
                        onPressed: () => setState(() {
                          _future = ref
                              .read(placesServiceProvider)
                              .search(widget.criteria.toPlacesQuery());
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.accent),
              );
            }
            final venues = snapshot.data ?? const [];
            if (venues.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    'No places match those choices. Try widening your budget or '
                    'distance.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl,
                  AppSpacing.xl, AppSpacing.navBarClearance),
              itemCount: venues.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, i) {
                if (i == 0) return const SampleDataNotice();
                final v = venues[i - 1];
                return VenueDateCard(
                  venue: v,
                  onViewPlace: () => _viewPlace(v),
                  onBuildDate: () => _buildDate(v),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
