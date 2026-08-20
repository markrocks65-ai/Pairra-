import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/preference_config.dart';
import '../domain/onboarding_profile.dart';
import '../domain/onboarding_repository.dart';
import 'onboarding_steps.dart';

/// Immutable onboarding state: the draft plus load/save flags. The set of
/// applicable [steps] is derived from the draft so the flow adapts (e.g. the
/// roles step only appears when a role vocabulary applies).
@immutable
class OnboardingState {
  const OnboardingState({
    required this.draft,
    this.loading = true,
    this.saving = false,
  });

  final OnboardingProfile draft;
  final bool loading;
  final bool saving;

  /// Steps that apply to this user, in order. Progressive disclosure + skip:
  /// the roles step is omitted when no [RoleSet] applies.
  List<OnboardingStep> get steps {
    final rolesApply = PreferenceConfig.roleSetFor(
          genderId: draft.genderId,
          orientationId: draft.orientationId,
        ) !=
        null;
    return [
      for (final s in OnboardingStep.values)
        if (s != OnboardingStep.roles || rolesApply) s,
    ];
  }

  OnboardingState copyWith({
    OnboardingProfile? draft,
    bool? loading,
    bool? saving,
  }) =>
      OnboardingState(
        draft: draft ?? this.draft,
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
      );
}

/// Owns the onboarding draft for the current user. Every field change flows
/// through [update], which mutates the draft and persists it (so progress is
/// always resumable). The controller is recreated per-user by its provider.
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._repo, this._uid)
      : super(OnboardingState(
          draft: const OnboardingProfile(),
          loading: _uid != null,
        )) {
    if (_uid != null) _load();
  }

  final OnboardingRepository _repo;
  final String? _uid;

  /// Field edits arrive keystroke-by-keystroke; without debouncing that's one
  /// Firestore write per character — costly in reads/writes, network and
  /// battery. We coalesce rapid edits into a single write after a short pause,
  /// and flush immediately on meaningful transitions (finish/skip) and teardown.
  static const Duration _persistDebounce = Duration(milliseconds: 600);
  Timer? _debounce;
  OnboardingProfile? _pendingSave;

  Future<void> _load() async {
    try {
      final draft = await _repo.load(_uid!);
      if (mounted) state = OnboardingState(draft: draft, loading: false);
    } catch (_) {
      // Load failed (offline with no cache / permission error). Don't hang on
      // the loading state or surface a raw exception — start from a fresh draft;
      // the debounced save will persist once connectivity/permissions recover.
      if (mounted) {
        state = const OnboardingState(
            draft: OnboardingProfile(), loading: false);
      }
    }
  }

  /// Applies [mutate] to the draft, upgrades status to inProgress on first
  /// edit, and (debounced) persists. This is the single entry point the UI uses
  /// for every field so persistence/resume behavior lives in one place.
  void update(OnboardingProfile Function(OnboardingProfile draft) mutate) {
    var next = mutate(state.draft);
    if (next.status == OnboardingStatus.notStarted) {
      next = next.copyWith(status: OnboardingStatus.inProgress);
    }
    state = state.copyWith(draft: next);
    _schedulePersist(next);
  }

  /// Marks the flow as started (so the router stops force-redirecting into it).
  void markStarted() {
    if (state.draft.status == OnboardingStatus.notStarted) {
      update((p) => p);
    }
  }

  /// User chose to finish later. Draft is kept; they can resume from Home.
  void skipForNow() {
    update((p) => p.copyWith(status: OnboardingStatus.skipped));
    _flushPending(); // a terminal choice — don't wait out the debounce.
  }

  /// Completes onboarding and stamps the completion time.
  void finish() {
    update((p) => p.copyWith(
          status: OnboardingStatus.complete,
          completedAt: DateTime.now(),
        ));
    _flushPending(); // persist completion promptly.
  }

  void _schedulePersist(OnboardingProfile profile) {
    if (_uid == null) return;
    _pendingSave = profile;
    state = state.copyWith(saving: true);
    _debounce?.cancel();
    _debounce = Timer(_persistDebounce, _flushPending);
  }

  Future<void> _flushPending() async {
    _debounce?.cancel();
    _debounce = null;
    final profile = _pendingSave;
    if (_uid == null || profile == null) return;
    _pendingSave = null;
    try {
      await _repo.save(_uid, profile);
    } catch (_) {
      // Best-effort persistence: the in-memory state is already updated, and a
      // failed write must not become an unhandled async error (it runs unawaited
      // from the debounce timer / finish / skip).
    } finally {
      if (mounted) state = state.copyWith(saving: false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    // Best-effort flush so an in-flight edit isn't lost when the controller is
    // torn down (e.g. sign-out); fire-and-forget since dispose can't await, and
    // errors are swallowed so a teardown-time write can never surface as an
    // unhandled async error.
    final pending = _pendingSave;
    if (_uid != null && pending != null) {
      _pendingSave = null;
      _repo.save(_uid, pending).catchError((_) {});
    }
    super.dispose();
  }
}
