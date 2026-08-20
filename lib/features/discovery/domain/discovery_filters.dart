import 'package:flutter/foundation.dart';

/// User-controlled discovery filters. Applied to already-scored candidates in
/// the controller (never in the UI).
///
/// Deliberately excludes filtering by another user's sexual role/position:
/// that is sensitive data and platform policy discourages filtering on it. The
/// compatibility threshold captures that dimension indirectly and privately.
@immutable
class DiscoveryFilters {
  const DiscoveryFilters({
    this.ageMin = 18,
    this.ageMax = 99,
    this.maxDistanceKm,
    this.intentions = const {},
    this.minCompatibility = 0,
    this.interests = const {},
    this.smoking = const {},
    this.drinking = const {},
    this.verifiedOnly = false,
  });

  final int ageMin;
  final int ageMax;

  /// Null = any distance.
  final double? maxDistanceKm;

  /// Empty = any. Candidate must share at least one intention.
  final Set<String> intentions;

  /// 0–100 minimum overall compatibility.
  final int minCompatibility;

  /// Empty = any. Candidate must share at least one interest.
  final Set<String> interests;

  final Set<String> smoking;
  final Set<String> drinking;

  /// Show only verified profiles (no-op until verification ships).
  final bool verifiedOnly;

  static const DiscoveryFilters initial = DiscoveryFilters();

  bool get isDefault =>
      ageMin == 18 &&
      ageMax == 99 &&
      maxDistanceKm == null &&
      intentions.isEmpty &&
      minCompatibility == 0 &&
      interests.isEmpty &&
      smoking.isEmpty &&
      drinking.isEmpty &&
      !verifiedOnly;

  /// The number of active (non-default) filter groups — for a UI badge.
  int get activeCount {
    var n = 0;
    if (ageMin != 18 || ageMax != 99) n++;
    if (maxDistanceKm != null) n++;
    if (intentions.isNotEmpty) n++;
    if (minCompatibility > 0) n++;
    if (interests.isNotEmpty) n++;
    if (smoking.isNotEmpty) n++;
    if (drinking.isNotEmpty) n++;
    if (verifiedOnly) n++;
    return n;
  }

  DiscoveryFilters copyWith({
    int? ageMin,
    int? ageMax,
    Object? maxDistanceKm = _sentinel,
    Set<String>? intentions,
    int? minCompatibility,
    Set<String>? interests,
    Set<String>? smoking,
    Set<String>? drinking,
    bool? verifiedOnly,
  }) {
    return DiscoveryFilters(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      maxDistanceKm: identical(maxDistanceKm, _sentinel)
          ? this.maxDistanceKm
          : maxDistanceKm as double?,
      intentions: intentions ?? this.intentions,
      minCompatibility: minCompatibility ?? this.minCompatibility,
      interests: interests ?? this.interests,
      smoking: smoking ?? this.smoking,
      drinking: drinking ?? this.drinking,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }

  static const _sentinel = Object();
}
