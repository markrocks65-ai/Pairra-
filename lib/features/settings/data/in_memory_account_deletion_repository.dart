import '../domain/account_deletion_repository.dart';
import '../domain/deletion_request.dart';

/// In-memory stand-in for the deletion workflow queue. In production this
/// writes a request that a Cloud Function picks up to perform the authoritative
/// permanent removal/anonymization across collections.
class InMemoryAccountDeletionRepository implements AccountDeletionRepository {
  final List<DeletionRequest> requests = [];

  @override
  Future<void> submit(DeletionRequest request) async {
    requests.add(request);
  }
}
