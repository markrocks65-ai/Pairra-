import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/subscription/application/subscription_controller.dart';
import 'package:pairra/features/subscription/data/mock_subscription_repository.dart';
import 'package:pairra/features/subscription/domain/premium_feature.dart';
import 'package:pairra/features/subscription/domain/subscription_models.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  group('Feature catalogue', () {
    test('safety is a free feature, never premium', () {
      expect(FreeFeatures.items, contains('All safety tools'));
      expect(FreeFeatures.items, contains('Blocking & reporting'));
      // Premium features don't include any safety capability.
      final premiumTitles =
          PremiumFeature.values.map((f) => f.title.toLowerCase());
      expect(premiumTitles.any((t) => t.contains('safety')), isFalse);
      expect(premiumTitles.any((t) => t.contains('block')), isFalse);
    });
  });

  group('Entitlement.isPremium', () {
    final now = DateTime.now();

    test('active premium is premium', () {
      expect(
        Entitlement(
                tier: SubscriptionTier.premium,
                expiresAt: now.add(const Duration(days: 1)))
            .isPremium,
        isTrue,
      );
    });

    test('expired premium is NOT premium', () {
      expect(
        Entitlement(
                tier: SubscriptionTier.premium,
                expiresAt: now.subtract(const Duration(seconds: 1)))
            .isPremium,
        isFalse,
        reason: 'an expired subscription must not keep unlocking premium',
      );
    });

    test('premium with no expiry (e.g. lifetime) stays premium', () {
      expect(
        const Entitlement(tier: SubscriptionTier.premium).isPremium,
        isTrue,
      );
    });

    test('free is never premium', () {
      expect(const Entitlement.free().isPremium, isFalse);
    });
  });

  group('MockSubscriptionRepository', () {
    test('is not configured and prices are sample (from the service)',
        () async {
      final repo = MockSubscriptionRepository(latency: Duration.zero);
      expect(repo.isConfigured, isFalse);
      final offerings = await repo.fetchOfferings();
      expect(offerings, isNotEmpty);
      expect(offerings.every((p) => p.isSamplePricing), isTrue);
      expect(offerings.every((p) => p.priceString.isNotEmpty), isTrue);
      repo.dispose();
    });

    test('a dev purchase grants a clearly-labelled dev entitlement', () async {
      final repo = MockSubscriptionRepository(latency: Duration.zero);
      final offerings = await repo.fetchOfferings();
      final result = await repo.purchase(offerings.first);
      expect(result.isSuccess, isTrue);
      expect(result.entitlement!.isPremium, isTrue);
      expect(result.entitlement!.isDevGrant, isTrue);
      repo.dispose();
    });
  });

  group('SubscriptionController', () {
    test('loads offerings and flips to premium after purchase', () async {
      final controller =
          SubscriptionController(MockSubscriptionRepository(latency: Duration.zero));
      await _settle();

      expect(controller.state.isConfigured, isFalse);
      expect(controller.state.offerings, isNotEmpty);
      expect(controller.state.isPremium, isFalse);

      await controller.purchase(controller.state.offerings.first);
      await _settle();

      expect(controller.state.isPremium, isTrue);
      expect(controller.state.entitlement.isDevGrant, isTrue);
      controller.dispose();
    });
  });
}
