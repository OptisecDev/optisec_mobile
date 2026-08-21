enum SubscriptionTier { free, pro }

enum SubscriptionProduct { proMonthly, proYearly, proLifetime }

class ProductIds {
  ProductIds._();

  static const String proMonthly = 'optisec_pro_monthly';
  static const String proYearly = 'optisec_pro_yearly';
  static const String proLifetime = 'optisec_pro_lifetime';

  static const Set<String> all = {proMonthly, proYearly, proLifetime};
}

/// Where a granted Pro entitlement came from -- used only for display
/// (e.g. Settings showing "Licensed to ...") and diagnostics, not for any
/// gating logic (that's `isPro` alone, regardless of source).
enum EntitlementSource { iap, licenseKey }

class SubscriptionModel {
  final SubscriptionTier tier;
  final DateTime? expiryDate;
  final bool isActive;
  final EntitlementSource? source;
  final String? licenseeLabel;

  const SubscriptionModel({
    required this.tier,
    this.expiryDate,
    required this.isActive,
    this.source,
    this.licenseeLabel,
  });

  factory SubscriptionModel.free() => const SubscriptionModel(
        tier: SubscriptionTier.free,
        isActive: true,
      );

  factory SubscriptionModel.pro({
    DateTime? expiryDate,
    required EntitlementSource source,
    String? licenseeLabel,
  }) =>
      SubscriptionModel(
        tier: SubscriptionTier.pro,
        expiryDate: expiryDate,
        isActive: true,
        source: source,
        licenseeLabel: licenseeLabel,
      );

  bool get isPro => tier == SubscriptionTier.pro && isActive;

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'expiryDate': expiryDate?.toIso8601String(),
        'isActive': isActive,
        'source': source?.name,
        'licenseeLabel': licenseeLabel,
      };

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      isActive: json['isActive'] as bool? ?? false,
      source: json['source'] == null
          ? null
          : EntitlementSource.values.firstWhere(
              (s) => s.name == json['source'],
              orElse: () => EntitlementSource.iap,
            ),
      licenseeLabel: json['licenseeLabel'] as String?,
    );
  }
}

class FeatureGate {
  FeatureGate._();

  static const int freeScansPerDay = 3;
  static const int freeAppLockLimit = 1;
  static const int freeVaultEntryLimit = 12;
}
