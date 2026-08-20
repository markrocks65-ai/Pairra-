import 'package:flutter/foundation.dart';

enum SubscriptionTier { free, premium }

/// The user's current entitlement. Sourced from the subscription provider
/// (RevenueCat customer info) — never trusted from the client alone in
/// production (a webhook keeps the server copy authoritative).
@immutable
class Entitlement {
  const Entitlement({
    this.tier = SubscriptionTier.free,
    this.expiresAt,
    this.willRenew = false,
    this.managementUrl,
    this.isDevGrant = false,
  });

  const Entitlement.free() : this();

  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool willRenew;
  final String? managementUrl;

  /// True when granted by the development mock rather than a real purchase.
  final bool isDevGrant;

  /// Premium only counts while the entitlement is actually active. A premium
  /// tier whose [expiresAt] is in the past is treated as free — so an expired
  /// subscription never keeps unlocking gated features. A null [expiresAt] means
  /// no expiry (e.g. lifetime), so it stays premium.
  bool get isPremium =>
      tier == SubscriptionTier.premium &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}

enum PackagePeriod {
  weekly('per week'),
  monthly('per month'),
  annual('per year'),
  lifetime('one-time');

  const PackagePeriod(this.suffix);
  final String suffix;
}

/// A purchasable package. **[priceString] comes from the store** (localized) via
/// the subscription service — it is never hard-coded or computed in the UI.
@immutable
class SubscriptionPackage {
  const SubscriptionPackage({
    required this.id,
    required this.title,
    required this.priceString,
    required this.period,
    this.perMonthString,
    this.savingsLabel,
    this.isSamplePricing = false,
  });

  final String id;
  final String title;

  /// Localized price string from the store (e.g. "$14.99").
  final String priceString;

  final PackagePeriod period;

  /// Optional derived "$X / mo" string (also provided by the service).
  final String? perMonthString;

  /// Optional "Save 30%" style label.
  final String? savingsLabel;

  /// True when the price is placeholder/sample data (no real store connected).
  final bool isSamplePricing;
}

/// Outcome of a purchase attempt.
enum PurchaseOutcome { success, cancelled, notAvailable, error }

@immutable
class PurchaseResult {
  const PurchaseResult(this.outcome, {this.entitlement, this.message});

  final PurchaseOutcome outcome;
  final Entitlement? entitlement;
  final String? message;

  bool get isSuccess => outcome == PurchaseOutcome.success;
}
