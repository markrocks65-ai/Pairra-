import 'deletion_request.dart';

/// Seam for the account-deletion backend workflow. Filing a [DeletionRequest]
/// hands off to a server process (Cloud Function) that PERMANENTLY removes or
/// anonymizes the user's data across every collection — profile, matches,
/// messages, media, subscriptions — according to the data-retention policy, and
/// deletes the auth identity. This is not a deactivation and is not reversible.
abstract interface class AccountDeletionRepository {
  Future<void> submit(DeletionRequest request);
}
