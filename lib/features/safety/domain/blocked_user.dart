import 'package:flutter/foundation.dart';

/// A blocked user. Stores an optional [name] so the Safety Center can show a
/// readable blocklist (the match/profile may no longer be available once
/// blocked).
@immutable
class BlockedUser {
  const BlockedUser(this.id, {this.name});

  final String id;
  final String? name;

  String get displayName => (name ?? '').trim().isEmpty ? 'Blocked user' : name!;
}
