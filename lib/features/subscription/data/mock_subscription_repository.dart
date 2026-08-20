import 'dart:async';

import '../domain/subscription_models.dart';
import '../domain/subscription_repository.dart';

/// Development [SubscriptionRepository]. It is NOT configured with a real
/// billing provider, so the paywall labels itself a development build and no
/// real charge ever occurs. Prices here are clearly-marked SAMPLE values
/// (`isSamplePricing`), delivered through the service exactly as a real store
/// would deliver localized prices — the UI never hard-codes them.
///
/// So premium-gated features can be exercised in development, a "purchase"
/// grants a clearly-labelled dev entitlement ([Entitlement.isDevGrant]).
/// Replace with `RevenueCatSubscriptionRepository` to go live.
class MockSubscriptionRepository implements SubscriptionRepository {
  MockSubscriptionRepository({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;
  final _controller = StreamController<Entitlement>.broadcast();
  Entitlement _current = const Entitlement.free();

  @override
  bool get isConfigured => false;

  @override
  Entitlement get currentEntitlement => _current;

  @override
  Stream<Entitlement> entitlementChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<List<SubscriptionPackage>> fetchOfferings() async {
    await Future<void>.delayed(latency);
    return const [
      SubscriptionPackage(
        id: 'pairra_premium_annual',
        title: 'Annual',
        priceString: '\$89.99',
        period: PackagePeriod.annual,
        perMonthString: '\$7.50 / mo',
        savingsLabel: 'Best value',
        isSamplePricing: true,
      ),
      SubscriptionPackage(
        id: 'pairra_premium_monthly',
        title: 'Monthly',
        priceString: '\$14.99',
        period: PackagePeriod.monthly,
        perMonthString: '\$14.99 / mo',
        isSamplePricing: true,
      ),
    ];
  }

  @override
  Future<PurchaseResult> purchase(SubscriptionPackage package) async {
    await Future<void>.delayed(latency);
    _current = Entitlement(
      tier: SubscriptionTier.premium,
      willRenew: false,
      isDevGrant: true,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    _controller.add(_current);
    return PurchaseResult(
      PurchaseOutcome.success,
      entitlement: _current,
      message: 'Development build — no real charge was made.',
    );
  }

  @override
  Future<Entitlement> restore() async {
    await Future<void>.delayed(latency);
    return _current;
  }

  @override
  void dispose() => _controller.close();
}
