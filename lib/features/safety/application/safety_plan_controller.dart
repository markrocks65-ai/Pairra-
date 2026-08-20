import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/safety_plan.dart';

/// Stores the user's safety plans (session-scoped; Firestore-ready later). The
/// actual check-in reminder would be delivered by a scheduled local
/// notification in production; here the pending check-in surfaces in the Safety
/// Center so the flow is complete.
class SafetyPlansController extends StateNotifier<List<SafetyPlan>> {
  SafetyPlansController() : super(const []);

  void add(SafetyPlan plan) => state = [plan, ...state];

  void remove(String id) => state = state.where((p) => p.id != id).toList();

  /// Marks the plan complete and clears its check-in ("I'm safe").
  void markSafe(String id) {
    state = [
      for (final p in state)
        p.id == id ? p.copyWith(status: SafetyPlanStatus.completed) : p,
    ];
  }

  List<SafetyPlan> get active => state.where((p) => p.isActive).toList();

  List<SafetyPlan> get pendingCheckIns =>
      state.where((p) => p.hasPendingCheckIn).toList();

  void clear() => state = const [];
}

final safetyPlansProvider =
    StateNotifierProvider<SafetyPlansController, List<SafetyPlan>>(
  (ref) => SafetyPlansController(),
);
