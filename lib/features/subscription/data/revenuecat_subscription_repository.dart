import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
// Hide RevenueCat's PurchaseResult — this app has its own PurchaseResult model.
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;

import '../domain/subscription_models.dart';
import '../domain/subscription_repository.dart';
import 'revenuecat_config.dart';

/// Production [SubscriptionRepository] backed by RevenueCat. Prices, packages
/// and entitlements come entirely from RevenueCat/StoreKit — nothing is
/// hard-coded. The SERVER copy of the plan stays authoritative via the
/// RevenueCat → Cloud Function webhook (revenueCatWebhook); this client view is
/// for gating UI responsively. Configure RevenueCat once (see [configure]).
class RevenueCatSubscriptionRepository implements SubscriptionRepository {
  RevenueCatSubscriptionRepository({String? entitlementId})
      : _entitlementId =
            entitlementId ?? RevenueCatConfig.premiumEntitlementId {
    _listener = (CustomerInfo info) {
      _current = _entitlementFrom(info);
      if (!_controller.isClosed) _controller.add(_current);
    };
    Purchases.addCustomerInfoUpdateListener(_listener);
    _refresh();
  }

  final String _entitlementId;
  final _controller = StreamController<Entitlement>.broadcast();
  late final void Function(CustomerInfo) _listener;
  Entitlement _current = const Entitlement.free();

  @override
  bool get isConfigured => RevenueCatConfig.isConfigured;

  Future<void> _refresh() async {
    try {
      _current = _entitlementFrom(await Purchases.getCustomerInfo());
      if (!_controller.isClosed) _controller.add(_current);
    } catch (_) {
      /* leave as free until the store responds */
    }
  }

  Entitlement _entitlementFrom(CustomerInfo info) {
    final ent = info.entitlements.active[_entitlementId];
    if (ent == null || !ent.isActive) return const Entitlement.free();
    return Entitlement(
      tier: SubscriptionTier.premium,
      expiresAt:
          ent.expirationDate == null ? null : DateTime.tryParse(ent.expirationDate!),
      willRenew: ent.willRenew,
      managementUrl: info.managementURL,
    );
  }

  @override
  Entitlement get currentEntitlement => _current;

  @override
  Stream<Entitlement> entitlementChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<List<SubscriptionPackage>> fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const [];
      return current.availablePackages.map(_packageFrom).toList();
    } catch (_) {
      return const [];
    }
  }

  SubscriptionPackage _packageFrom(Package package) {
    final p = package.storeProduct;
    return SubscriptionPackage(
      id: package.identifier,
      title: p.title.isNotEmpty ? p.title : _periodOf(package).name,
      priceString: p.priceString,
      period: _periodOf(package),
    );
  }

  PackagePeriod _periodOf(Package package) {
    switch (package.packageType) {
      case PackageType.annual:
        return PackagePeriod.annual;
      case PackageType.monthly:
        return PackagePeriod.monthly;
      case PackageType.weekly:
        return PackagePeriod.weekly;
      case PackageType.lifetime:
        return PackagePeriod.lifetime;
      default:
        return PackagePeriod.monthly;
    }
  }

  @override
  Future<PurchaseResult> purchase(SubscriptionPackage package) async {
    try {
      final offerings = await Purchases.getOfferings();
      final rcPackage = offerings.current?.availablePackages
          .firstWhere((p) => p.identifier == package.id);
      if (rcPackage == null) {
        return const PurchaseResult(PurchaseOutcome.notAvailable,
            message: 'That plan is unavailable right now.');
      }
      // purchasePackage is stable; the newer purchase(PurchaseParams) API
      // varies across SDK majors.
      // ignore: deprecated_member_use
      final rcResult = await Purchases.purchasePackage(rcPackage);
      _current = _entitlementFrom(rcResult.customerInfo);
      if (!_controller.isClosed) _controller.add(_current);
      return PurchaseResult(
        _current.isPremium ? PurchaseOutcome.success : PurchaseOutcome.error,
        entitlement: _current,
        message: _current.isPremium ? 'You\'re all set — welcome to Premium.' : null,
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseResult(PurchaseOutcome.cancelled);
      }
      return PurchaseResult(PurchaseOutcome.error, message: e.message);
    } catch (e) {
      return PurchaseResult(PurchaseOutcome.error, message: e.toString());
    }
  }

  @override
  Future<Entitlement> restore() async {
    try {
      _current = _entitlementFrom(await Purchases.restorePurchases());
      if (!_controller.isClosed) _controller.add(_current);
    } catch (_) {}
    return _current;
  }

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_listener);
    _controller.close();
  }
}
