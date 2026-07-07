import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../shared/models/subscription_model.dart';

/// Wraps the in_app_purchase package and exposes the current subscription
/// entitlement to the rest of the app.
///
/// NOTE: Entitlement here is granted purely from the client-side purchase
/// stream (`PurchaseStatus.purchased` / `PurchaseStatus.restored`). This is
/// NOT secure against tampering — it should be hardened with server-side
/// receipt validation (App Store / Play Billing) before relying on it to
/// gate anything high-value.
class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  static const _storageKey = 'subscription_state';

  final InAppPurchase _iap = InAppPurchase.instance;
  final _box = GetStorage();

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final ValueNotifier<SubscriptionModel> currentSubscription =
      ValueNotifier<SubscriptionModel>(SubscriptionModel.free());

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _loadPersistedSubscription();

    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );
  }

  void _loadPersistedSubscription() {
    final saved = _box.read<Map<String, dynamic>>(_storageKey);
    if (saved != null) {
      currentSubscription.value = SubscriptionModel.fromJson(saved);
    }
  }

  Future<ProductDetailsResponse> queryProducts() {
    return _iap.queryProductDetails(ProductIds.all);
  }

  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _grantEntitlement(purchase);
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void _grantEntitlement(PurchaseDetails purchase) {
    final product = _productFromId(purchase.productID);
    if (product == null) return;

    final subscription = SubscriptionModel.pro(
      product: product,
      expiryDate: product == SubscriptionProduct.proLifetime
          ? null
          : DateTime.now().add(
              product == SubscriptionProduct.proYearly
                  ? const Duration(days: 365)
                  : const Duration(days: 30),
            ),
    );

    currentSubscription.value = subscription;
    _box.write(_storageKey, subscription.toJson());
  }

  SubscriptionProduct? _productFromId(String productId) {
    switch (productId) {
      case ProductIds.proMonthly:
        return SubscriptionProduct.proMonthly;
      case ProductIds.proYearly:
        return SubscriptionProduct.proYearly;
      case ProductIds.proLifetime:
        return SubscriptionProduct.proLifetime;
      default:
        return null;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
