import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/services/license_key_service.dart';
import '../../../core/services/purchase_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';
import '../../../shared/models/subscription_model.dart';

class SubscriptionController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductDetails>[].obs;

  // The same Rx PurchaseService owns -- not a copy kept in sync via a
  // listener, so there's exactly one reactive source of truth for
  // entitlement state instead of two.
  Rx<SubscriptionModel> get subscription =>
      PurchaseService.instance.currentSubscription;

  final isActivatingLicense = false.obs;
  final licenseKeyError = RxnString();

  bool get isPro => subscription.value.isPro;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    isLoading.value = true;
    try {
      final response = await PurchaseService.instance.queryProducts();
      products.value = response.productDetails;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchase(ProductDetails product) async {
    isLoading.value = true;
    try {
      await PurchaseService.instance.buy(product);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restore() async {
    isLoading.value = true;
    try {
      await PurchaseService.instance.restorePurchases();
    } finally {
      isLoading.value = false;
    }
  }

  bool checkAccessOrPrompt({required String feature}) {
    if (isPro) return true;
    Get.toNamed(AppRoutes.paywall, arguments: {'feature': feature});
    return false;
  }

  /// Verifies and activates an offline license key. Returns `true` on
  /// success; on failure, [licenseKeyError] carries a message for the UI
  /// and the entitlement is left unchanged.
  Future<bool> activateLicenseKey(String rawKey) async {
    isActivatingLicense.value = true;
    licenseKeyError.value = null;
    try {
      final result = await LicenseKeyService.instance.activate(rawKey.trim());
      if (!result.isValid) {
        licenseKeyError.value = _messageFor(result);
        return false;
      }
      return true;
    } finally {
      isActivatingLicense.value = false;
    }
  }

  String _messageFor(LicenseVerification result) {
    final l10n = AppLocalizations.of(Get.context!);
    switch (result.error) {
      case LicenseKeyError.invalidFormat:
        return l10n.licenseKeyErrorInvalidFormat;
      case LicenseKeyError.invalidSignature:
        return l10n.licenseKeyErrorInvalidSignature;
      case LicenseKeyError.malformedPayload:
        return l10n.licenseKeyErrorMalformed;
      case LicenseKeyError.expired:
        final expiredOn = result.license?.expiresAt;
        return expiredOn == null
            ? l10n.licenseKeyErrorExpired
            : l10n.licenseKeyErrorExpiredOn(
                expiredOn.toLocal().toString().split(' ').first);
      case LicenseKeyError.deviceMismatch:
        return l10n.licenseKeyErrorDeviceMismatch;
      case null:
        return l10n.licenseKeyErrorUnknown;
    }
  }

}
