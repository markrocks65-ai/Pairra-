/// A token-bucket rate limiter that keeps the app within a provider's request
/// limits. [tryAcquire] is non-blocking: when no token is available the caller
/// should fall back to cache rather than hit the provider.
class RateLimiter {
  RateLimiter({
    this.capacity = 5,
    this.refillPerSecond = 1,
    DateTime Function()? clock,
  })  : _now = clock ?? DateTime.now,
        _tokens = capacity.toDouble() {
    _lastRefill = _now();
  }

  /// Max burst.
  final int capacity;

  /// Tokens added per second.
  final double refillPerSecond;

  final DateTime Function() _now;
  double _tokens;
  late DateTime _lastRefill;

  void _refill() {
    final now = _now();
    final elapsed = now.difference(_lastRefill).inMilliseconds / 1000.0;
    if (elapsed <= 0) return;
    _tokens = (_tokens + elapsed * refillPerSecond).clamp(0, capacity.toDouble());
    _lastRefill = now;
  }

  /// Consumes a token if available. Returns false when the limit is hit.
  bool tryAcquire() {
    _refill();
    if (_tokens >= 1) {
      _tokens -= 1;
      return true;
    }
    return false;
  }
}
