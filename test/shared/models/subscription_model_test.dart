import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/shared/models/subscription_model.dart';

void main() {
  group('SubscriptionModel', () {
    test('free() round-trips through JSON', () {
      final model = SubscriptionModel.free();
      final restored = SubscriptionModel.fromJson(model.toJson());

      expect(restored.tier, SubscriptionTier.free);
      expect(restored.isPro, isFalse);
      expect(restored.expiryDate, isNull);
      expect(restored.source, isNull);
      expect(restored.licenseeLabel, isNull);
    });

    test('pro() from a license key round-trips with lifetime (null expiry)', () {
      final model = SubscriptionModel.pro(
        source: EntitlementSource.licenseKey,
        licenseeLabel: 'buyer@example.com',
      );
      final restored = SubscriptionModel.fromJson(model.toJson());

      expect(restored.isPro, isTrue);
      expect(restored.expiryDate, isNull);
      expect(restored.source, EntitlementSource.licenseKey);
      expect(restored.licenseeLabel, 'buyer@example.com');
    });

    test('pro() from IAP round-trips with a set expiry', () {
      final expiry = DateTime.utc(2027, 1, 1);
      final model = SubscriptionModel.pro(
        source: EntitlementSource.iap,
        expiryDate: expiry,
      );
      final restored = SubscriptionModel.fromJson(model.toJson());

      expect(restored.isPro, isTrue);
      expect(restored.expiryDate, expiry);
      expect(restored.source, EntitlementSource.iap);
      expect(restored.licenseeLabel, isNull);
    });
  });
}
