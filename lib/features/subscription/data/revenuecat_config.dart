/// RevenueCat configuration, supplied at build time via --dart-define so no key
/// is committed. The iOS/Android SDK keys are the PUBLIC RevenueCat keys (safe
/// to ship in the binary). The paywall stays on the mock (no real charge) until
/// a key is provided, so debug builds never hit the store.
///
/// Build example:
///   flutter build ipa --dart-define=REVENUECAT_IOS_KEY=appl_XXXX
class RevenueCatConfig {
  const RevenueCatConfig._();

  static const String iosApiKey =
      String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const String androidApiKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  /// The RevenueCat entitlement identifier that unlocks Pairra premium. Create
  /// an entitlement with this id in the RevenueCat dashboard and attach your
  /// subscription products to it.
  static const String premiumEntitlementId =
      String.fromEnvironment('REVENUECAT_PREMIUM_ENTITLEMENT',
          defaultValue: 'premium');

  static bool get hasIosKey => iosApiKey.isNotEmpty;
  static bool get hasAndroidKey => androidApiKey.isNotEmpty;
  static bool get isConfigured => hasIosKey || hasAndroidKey;
}
