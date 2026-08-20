import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../compatibility/application/compatibility_service.dart';
import '../../compatibility/data/compatibility_profile_mapper.dart';
import '../../compatibility/domain/compatibility_score.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../../safety/application/safety_controllers.dart';
import '../domain/candidate.dart';
import '../domain/discovery_filters.dart';
import '../domain/discovery_repository.dart';
import '../domain/match.dart';
import 'matches_controller.dart';

/// A candidate paired with the compatibility assessment against the current
/// user, plus the precomputed approximate distance. Compatibility is computed
/// once here (in the controller), never in the UI.
@immutable
class ScoredCandidate {
  const ScoredCandidate({
    required this.candidate,
    required this.assessment,
    this.distanceKm,
  });

  final Candidate candidate;
  final CompatibilityAssessment assessment;
  final double? distanceKm;

  CompatibilityScore get score => assessment.score;
}

@immutable
class DiscoveryState {
  const DiscoveryState({
    this.queue = const [],
    this.filters = DiscoveryFilters.initial,
    this.loading = true,
  });

  final List<ScoredCandidate> queue;
  final DiscoveryFilters filters;
  final bool loading;

  ScoredCandidate? get current => queue.isEmpty ? null : queue.first;
  bool get exhausted => !loading && queue.isEmpty;

  DiscoveryState copyWith({
    List<ScoredCandidate>? queue,
    DiscoveryFilters? filters,
    bool? loading,
  }) =>
      DiscoveryState(
        queue: queue ?? this.queue,
        filters: filters ?? this.filters,
        loading: loading ?? this.loading,
      );
}

/// Drives the Discover feed: scores every candidate with the compatibility
/// engine (ranking most-compatible first), applies the user's filters and the
/// app-wide blocklist, and handles like / pass / maybe / block / report.
class DiscoveryController extends StateNotifier<DiscoveryState> {
  DiscoveryController(
    this._repository,
    this._service,
    this._self,
    this._matches,
    this._blocked, {
    bool premium = false,
    // ignore: prefer_initializing_formals — private named params can't be formals.
  })  : _premium = premium,
        super(const DiscoveryState()) {
    _load();
  }

  final DiscoveryRepository _repository;
  final CompatibilityService _service;
  final OnboardingProfile _self;
  final MatchesController _matches;
  final BlockedProfilesController _blocked;

  /// Free users get a limited number of likes; premium is unlimited. Safety
  /// actions (pass/block/report) are never limited.
  final bool _premium;
  static const int _freeLikeLimit = 12;
  int _likesUsed = 0;

  List<ScoredCandidate> _allScored = const [];
  final Set<String> _seen = {};
  final Set<String> _maybeIds = {};

  /// Whether the user can like right now (premium = always).
  bool get canLike => _premium || _likesUsed < _freeLikeLimit;

  /// Remaining free likes, or null when unlimited (premium).
  int? get remainingLikes =>
      _premium ? null : (_freeLikeLimit - _likesUsed).clamp(0, _freeLikeLimit);

  Future<void> _load() async {
    try {
      final candidates = await _repository.fetchCandidates();
      final me = CompatibilityProfileMapper.fromOnboarding(_self, id: 'self');
      final myLoc = me.location;

      _allScored = [
        for (final c in candidates)
          () {
            final other =
                CompatibilityProfileMapper.fromOnboarding(c.profile, id: c.id);
            final dist = (myLoc != null && other.location != null)
                ? myLoc.distanceKmTo(other.location!)
                : null;
            return ScoredCandidate(
              candidate: c,
              assessment: _service.evaluate(me, other),
              distanceKm: dist,
            );
          }(),
      ]..sort((a, b) => b.score.overall.compareTo(a.score.overall));

      if (mounted) _rebuild(loading: false);
    } catch (_) {
      // Fetch failed (no internet / provider error). Don't leave the feed
      // spinning forever or throw unhandled — settle into the (empty) exhausted
      // state, which renders the "all caught up" empty view.
      _allScored = const [];
      if (mounted) _rebuild(loading: false);
    }
  }

  void _rebuild({bool? loading}) {
    final queue = [
      for (final sc in _allScored)
        if (!_seen.contains(sc.candidate.id) &&
            !_blocked.isBlocked(sc.candidate.id) &&
            _passes(state.filters, sc))
          sc,
    ];
    state = state.copyWith(queue: queue, loading: loading ?? state.loading);
  }

  bool _passes(DiscoveryFilters f, ScoredCandidate sc) {
    final p = sc.candidate.profile;
    final age = p.age;
    if (age != null && (age < f.ageMin || age > f.ageMax)) return false;
    if (f.maxDistanceKm != null &&
        sc.distanceKm != null &&
        sc.distanceKm! > f.maxDistanceKm!) {
      return false;
    }
    if (f.intentions.isNotEmpty &&
        p.datingIntentions.intersection(f.intentions).isEmpty) {
      return false;
    }
    if (sc.score.percent < f.minCompatibility) return false;
    if (f.interests.isNotEmpty &&
        p.interests.intersection(f.interests).isEmpty) {
      return false;
    }
    if (f.smoking.isNotEmpty && !f.smoking.contains(p.lifestyle.smoking)) {
      return false;
    }
    if (f.drinking.isNotEmpty && !f.drinking.contains(p.lifestyle.drinking)) {
      return false;
    }
    if (f.verifiedOnly && !p.verification.hasBadge) return false;
    return true;
  }

  void setFilters(DiscoveryFilters filters) {
    state = state.copyWith(filters: filters);
    _rebuild();
  }

  /// Likes the current candidate. Returns a [Match] if it's mutual, else null.
  /// Does nothing when the free like limit is reached (callers check [canLike]
  /// first and present the paywall).
  Match? like() {
    final current = state.current;
    if (current == null || !canLike) return null;
    if (!_premium) _likesUsed++;
    _seen.add(current.candidate.id);
    Match? match;
    if (current.candidate.likesYou) {
      match = Match(
        id: current.candidate.id,
        profile: current.candidate.profile,
        compatibilityPercent: current.score.percent,
        matchedAt: DateTime.now(),
      );
      _matches.add(match);
    }
    _rebuild();
    return match;
  }

  void pass() {
    final current = state.current;
    if (current == null) return;
    _seen.add(current.candidate.id);
    _rebuild();
  }

  /// Defer a decision — removed from the current run, kept for later.
  void maybe() {
    final current = state.current;
    if (current == null) return;
    _seen.add(current.candidate.id);
    _maybeIds.add(current.candidate.id);
    _rebuild();
  }

  /// Blocks and removes the candidate from the queue. Filing the report itself
  /// goes through the moderation service in the UI layer (a report also blocks).
  void block(String candidateId, {String? name}) {
    _blocked.block(candidateId, name: name);
    _seen.add(candidateId);
    _rebuild();
  }
}
