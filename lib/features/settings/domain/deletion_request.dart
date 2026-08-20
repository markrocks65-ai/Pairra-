import 'package:flutter/foundation.dart';

/// How the user's data is handled on deletion. Some records may be anonymized
/// rather than removed where retention is legally required (e.g. moderation
/// history) — the server decides per the data-retention policy.
enum DeletionMode { deleteEverything, anonymize }

/// A request to permanently delete an account. Filing this triggers a
/// server-side workflow that removes or anonymizes the user's data across all
/// collections — it is NOT a deactivation.
@immutable
class DeletionRequest {
  const DeletionRequest({
    required this.uid,
    required this.requestedAt,
    this.mode = DeletionMode.deleteEverything,
    this.reason,
  });

  final String? uid;
  final DateTime requestedAt;
  final DeletionMode mode;
  final String? reason;
}
