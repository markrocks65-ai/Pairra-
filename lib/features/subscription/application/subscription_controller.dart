import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_subscription_repository.dart';
import '../domain/subscription_models.dart';
import '../domain/subscription_repository.dart';

@immutable
class SubscriptionState {
  const SubscriptionState({
    required this.entitlement,
    required this.isConfigured,
    this.offerings = const [],
    this.loadingOfferings = true,
    this.purchasing = false,
    this.message,
  });

  final Entitlement entitlement;
  final bool isConfigured;
  final List<SubscriptionPackage> offerings;
  final bool loadingOfferings;
  final bool purchasing;
  final String? message;

  bool get isPremium => entitlement.isPremium;

  SubscriptionState copyWith({
    Entitlement? entitlement,
    List<SubscriptionPackage>? offerings,
    bool? loadingOfferings,
    bool? purchasing,
    String? message,
    bool clearMessage = false,
  }) =>
      SubscriptionState(
        entitlement: entitlement ?? this.entitlement,
        isConfigured: isConfigured,
        offerings: offerings ?? this.offerings,
        loadingOfferings: loadingOfferings ?? this.loadingOfferings,
        purchasing: purchasing ?? this.purchasing,
        message: clearMessage ? null : (message ?? this.message),
      );
}

/// Owns subscription state: current entitlement, available offerings, and the
/// purchase/restore actions. Delegates all billing to [SubscriptionRepository].
class SubscriptionController extends StateNotifier<SubscriptionState> {
  SubscriptionController(this._repo)
      : super(SubscriptionState(
          entitlement: _repo.currentEntitlement,
          isConfigured: _repo.isConfigured,
        )) {
    _sub = _repo.entitlementChanges().listen((e) {
      state = state.copyWith(entitlement: e);
    });
    loadOfferings();
  }

  final SubscriptionRepository _repo;
  late final StreamSubscription<Entitlement> _sub;

  Future<void> loadOfferings() async {
    state = state.copyWith(loadingOfferings: true);
    final offerings = await _repo.fetchOfferings();
    if (mounted) {
      state = state.copyWith(offerings: offerings, loadingOfferings: false);
    }
  }

  Future<PurchaseResult> purchase(SubscriptionPackage package) async {
    state = state.copyWith(purchasing: true, clearMessage: true);
    final result = await _repo.purchase(package);
    if (mounted) {
      state = state.copyWith(purchasing: false, message: result.message);
    }
    return result;
  }

  Future<void> restore() async {
    state = state.copyWith(purchasing: true, clearMessage: true);
    await _repo.restore();
    if (mounted) state = state.copyWith(purchasing: false);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final repo = MockSubscriptionRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>(
  (ref) => SubscriptionController(ref.watch(subscriptionRepositoryProvider)),
);

/// Convenience: is the current user premium?
final isPremiumProvider = Provider<bool>(
  (ref) => ref.watch(
      subscriptionControllerProvider.select((s) => s.isPremium)),
);
