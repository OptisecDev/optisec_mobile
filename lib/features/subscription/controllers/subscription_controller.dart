import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/services/purchase_service.dart';
import '../../../navigation/app_routes.dart';
import '../../../shared/models/subscription_model.dart';

class SubscriptionController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductDetails>[].obs;
  late final Rx<SubscriptionModel> subscription;

  bool get isPro => subscription.value.isPro;

  @override
  void onInit() {
    super.onInit();
    subscription = PurchaseService.instance.currentSubscription.value.obs;
    PurchaseService.instance.currentSubscription.addListener(_onSubscriptionChanged);
    _loadProducts();
  }

  void _onSubscriptionChanged() {
    subscription.value = PurchaseService.instance.currentSubscription.value;
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

  @override
  void onClose() {
    PurchaseService.instance.currentSubscription.removeListener(_onSubscriptionChanged);
    super.onClose();
  }
}
