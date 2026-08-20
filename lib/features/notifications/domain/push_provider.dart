/// Seam for a push-notification transport (Firebase Cloud Messaging, APNs, …).
/// The app depends only on this; the default is [UnconnectedPushProvider], so
/// no real pushes are sent until a provider is configured.
abstract interface class PushProvider {
  bool get isConnected;
  Future<void> send({required String title, required String body});
}

/// Default: no push transport connected. In-app notifications still work.
class UnconnectedPushProvider implements PushProvider {
  const UnconnectedPushProvider();

  @override
  bool get isConnected => false;

  @override
  Future<void> send({required String title, required String body}) async {
    // No-op until FCM/APNs is wired up.
  }
}
