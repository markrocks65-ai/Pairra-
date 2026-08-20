import 'package:flutter/foundation.dart';

/// A venue's price tier plus a typical spend estimate for two, always expressed
/// as a range (never false precision). Providers map their own price level onto
/// [level] (1–4).
@immutable
class VenuePriceRange {
  const VenuePriceRange({
    required this.level,
    this.typicalForTwoMin = 0,
    this.typicalForTwoMax = 0,
    this.currencySymbol = '\$',
  });

  /// 1–4.
  final int level;

  /// Estimated spend for two, inclusive range.
  final int typicalForTwoMin;
  final int typicalForTwoMax;

  final String currencySymbol;

  /// "$$" style tier symbol.
  String get symbol => currencySymbol * level.clamp(1, 4);

  bool get isFree => typicalForTwoMin == 0 && typicalForTwoMax == 0;

  /// "$45–$65" (or "Free").
  String get estimateLabel => isFree
      ? 'Free'
      : '$currencySymbol$typicalForTwoMin–$currencySymbol$typicalForTwoMax';
}
