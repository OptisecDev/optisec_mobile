enum SubscriptionTier { free, pro }

enum SubscriptionProduct { proMonthly, proYearly, proLifetime }

class ProductIds {
  ProductIds._();

  static const String proMonthly = 'optisec_pro_monthly';
  static const String proYearly = 'optisec_pro_yearly';
  static const String proLifetime = 'optisec_pro_lifetime';

  static const Set<String> all = {proMonthly, proYearly, proLifetime};
}

class SubscriptionModel {
  final SubscriptionTier tier;
  final SubscriptionProduct? activeProduct;
  final DateTime? expiryDate;
  final bool isActive;

  const SubscriptionModel({
    required this.tier,
    this.activeProduct,
    this.expiryDate,
    required this.isActive,
  });

  factory SubscriptionModel.free() => const SubscriptionModel(
        tier: SubscriptionTier.free,
        isActive: true,
      );

  factory SubscriptionModel.pro({
    required SubscriptionProduct product,
    DateTime? expiryDate,
  }) =>
      SubscriptionModel(
        tier: SubscriptionTier.pro,
        activeProduct: product,
        expiryDate: expiryDate,
        isActive: true,
      );

  bool get isPro => tier == SubscriptionTier.pro && isActive;

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'activeProduct': activeProduct?.name,
        'expiryDate': expiryDate?.toIso8601String(),
        'isActive': isActive,
      };

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      activeProduct: json['activeProduct'] == null
          ? null
          : SubscriptionProduct.values.firstWhere(
              (p) => p.name == json['activeProduct'],
              orElse: () => SubscriptionProduct.proMonthly,
            ),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class FeatureGate {
  FeatureGate._();

  static const int freeScansPerDay = 3;

  static const bool wifiUnlimitedScans = true;
  static const bool weeklySecurityReport = true;
  static const bool advancedLessons = true;
  static const bool evilTwinDeepAnalysis = true;
  static const bool pdfExport = true;
}
