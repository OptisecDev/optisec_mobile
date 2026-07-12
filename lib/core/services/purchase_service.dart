import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../shared/models/subscription_model.dart';

/// Wraps the in_app_purchase package and exposes the current subscription
/// entitlement to the rest of the app.
///
/// NOTE: Entitlement is granted from the client-side purchase stream
/// (`PurchaseStatus.purchased` / `PurchaseStatus.restored`), gated on a
/// local RSA signature check against the Play Console license public key
/// (see [_isSignatureValid] and PurchaseChannelHandler.kt). That is
/// client-side hardening only, not a replacement for server-side receipt
/// validation — a rooted/instrumented device can still patch around a
/// local check. True tamper-resistance requires a backend that re-verifies
/// the purchase token against the Play Developer / App Store Server API;
/// this app has no backend today, so that remains a known, accepted
/// limitation rather than something this pass claims to fully solve.
class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  static const _storageKey = 'subscription_state';
  static const _verificationChannel =
      MethodChannel('com.optisec.mobile/purchase_verification');

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

    bool available;
    try {
      available = await _iap.isAvailable();
    } catch (_) {
      // No in_app_purchase platform implementation on this platform
      // (e.g. desktop) — fall back to the free tier instead of crashing.
      return;
    }
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
          if (await _isSignatureValid(purchase)) {
            _grantEntitlement(purchase);
          } else {
            debugPrint(
              'PurchaseService: signature verification failed for '
              '${purchase.productID} — entitlement not granted.',
            );
          }
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

  /// Verifies [purchase]'s signature locally against this app's Play
  /// Console license public key before its status is trusted. See the
  /// class-level note above on the limits of client-side verification.
  ///
  /// Returns `true` (trust the status as before) for non-Android purchases
  /// or if the native public key isn't configured yet — see
  /// PurchaseChannelHandler.kt — so this fails open to today's behavior
  /// rather than blocking every purchase on a missing key or a platform
  /// channel wiring issue.
  Future<bool> _isSignatureValid(PurchaseDetails purchase) async {
    if (purchase is! GooglePlayPurchaseDetails) {
      // iOS (StoreKit) purchases aren't covered by this Play-specific
      // signature check; out of scope for this pass.
      return true;
    }

    final billingPurchase = purchase.billingClientPurchase;
    try {
      final verified = await _verificationChannel.invokeMethod<bool?>(
        'verifyPurchaseSignature',
        {
          'signedData': billingPurchase.originalJson,
          'signature': billingPurchase.signature,
        },
      );
      // null == native public key not configured yet — fall back to
      // status-only trust rather than rejecting every purchase.
      return verified ?? true;
    } catch (_) {
      return true;
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
