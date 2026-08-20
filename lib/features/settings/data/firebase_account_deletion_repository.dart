import 'package:cloud_functions/cloud_functions.dart';

import '../domain/account_deletion_repository.dart';
import '../domain/deletion_request.dart';

/// Production [AccountDeletionRepository]. Invokes the server-side
/// `deleteAccount` Cloud Function, which performs the authoritative, permanent
/// cascade — removes the public profile projection, unmatches + closes
/// conversations, deletes game sessions/date plans/purchases, recursively
/// deletes all private subcollections and the user document, purges profile
/// photos from Storage, and finally deletes the Firebase Auth user. The client
/// never performs the deletion itself (it can't be trusted to be complete); it
/// only asks the server to do it. See functions/index.js (exports.deleteAccount).
class FirebaseAccountDeletionRepository implements AccountDeletionRepository {
  FirebaseAccountDeletionRepository([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<void> submit(DeletionRequest request) async {
    // The callable derives the uid from the authenticated token and takes no
    // arguments; it runs with Admin privileges so it isn't subject to the
    // client's `requires-recent-login` reauth constraint.
    await _functions.httpsCallable('deleteAccount').call();
  }
}
