import 'subscription_models.dart';

/// Provider-agnostic subscription contract. A concrete implementation wraps
/// RevenueCat (or StoreKit / Play Billing directly); the app depends only on
/// this. Pricing always comes FROM the provider — the UI never hard-codes it.
///
/// [isConfigured] is false until a real billing provider + store products are
/// connected; the paywall then labels itself as a development build and no real
/// charge occurs.
abstract interface class SubscriptionRepository {
  bool get isConfigured;

  /// Available packages, with store-provided localized prices.
  Future<List<SubscriptionPackage>> fetchOfferings();

  /// The current entitlement, and a stream of changes.
  Entitlement get currentEntitlement;
  Stream<Entitlement> entitlementChanges();

  /// Starts the store purchase flow for [package]. In production this is the
  /// RevenueCat/StoreKit purchase; the user confirms in the OS sheet.
  Future<PurchaseResult> purchase(SubscriptionPackage package);

  /// Restores prior purchases.
  Future<Entitlement> restore();

  void dispose();
}
