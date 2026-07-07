import 'package:get/get.dart';

import '../../../core/services/app_lock_service.dart';
import '../../../navigation/app_routes.dart';
import '../../../shared/models/installed_app_info.dart';
import '../../../shared/models/subscription_model.dart';
import '../../subscription/controllers/subscription_controller.dart';

class AppLockController extends GetxController {
  final isLoading = true.obs;
  final installedApps = <InstalledAppInfo>[].obs;
  final lockedPackages = <String>{}.obs;
  final searchQuery = ''.obs;

  final isPinSet = false.obs;
  final hasOverlayPermission = false.obs;
  final isIgnoringBatteryOptimizations = true.obs;

  bool get showBatteryOptimizationBanner =>
      lockedPackages.isNotEmpty && !isIgnoringBatteryOptimizations.value;

  List<InstalledAppInfo> get filteredApps {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return installedApps;
    return installedApps
        .where((app) => app.appName.toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        AppLockService.instance.getInstalledApps(),
        AppLockService.instance.getLockedApps(),
        AppLockService.instance.isPinSet(),
        AppLockService.instance.hasOverlayPermission(),
        AppLockService.instance.isIgnoringBatteryOptimizations(),
      ]);
      installedApps.value = results[0] as List<InstalledAppInfo>;
      lockedPackages.assignAll(results[1] as Set<String>);
      isPinSet.value = results[2] as bool;
      hasOverlayPermission.value = results[3] as bool;
      isIgnoringBatteryOptimizations.value = results[4] as bool;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPermissionStatus() async {
    hasOverlayPermission.value =
        await AppLockService.instance.hasOverlayPermission();
    isIgnoringBatteryOptimizations.value =
        await AppLockService.instance.isIgnoringBatteryOptimizations();
    isPinSet.value = await AppLockService.instance.isPinSet();
  }

  bool isLocked(String packageName) => lockedPackages.contains(packageName);

  Future<void> toggleLock(String packageName) async {
    if (!isPinSet.value) {
      Get.toNamed(AppRoutes.pinSetup);
      return;
    }

    if (lockedPackages.contains(packageName)) {
      lockedPackages.remove(packageName);
    } else {
      final isFirstLockedApp = lockedPackages.isEmpty;
      if (!isFirstLockedApp) {
        final subscriptionController = Get.find<SubscriptionController>();
        if (lockedPackages.length >= FeatureGate.freeAppLockLimit &&
            !subscriptionController.checkAccessOrPrompt(feature: 'app_lock')) {
          return;
        }
      }
      lockedPackages.add(packageName);
    }

    await AppLockService.instance.setLockedApps(lockedPackages.toSet());

    if (lockedPackages.isNotEmpty) {
      await AppLockService.instance.startMonitorService();
    } else {
      await AppLockService.instance.stopMonitorService();
    }
  }

  Future<void> openOverlaySettings() async {
    await AppLockService.instance.openOverlaySettings();
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    await AppLockService.instance.requestIgnoreBatteryOptimizations();
  }
}
