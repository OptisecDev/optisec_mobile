import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../navigation/app_routes.dart';
import '../controllers/app_lock_controller.dart';
import '../widgets/app_lock_tile.dart';
import '../widgets/battery_optimization_banner.dart';

class AppLockSettingsView extends GetView<AppLockController> {
  const AppLockSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('App Lock'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPermissionStatus,
          child: Column(
            children: [
              if (!controller.isPinSet.value) _PinSetupPrompt(),
              if (!controller.hasOverlayPermission.value)
                _OverlayPermissionPrompt(controller: controller),
              if (controller.showBatteryOptimizationBanner)
                BatteryOptimizationBanner(
                  onFix: controller.requestIgnoreBatteryOptimizations,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search apps',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textDisabled,
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  final apps = controller.filteredApps;
                  if (apps.isEmpty) {
                    return const Center(
                      child: Text(
                        'No apps found',
                        style: TextStyle(color: AppColors.textDisabled),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return AppLockTile(
                        app: app,
                        isLocked: controller.isLocked(app.packageName),
                        onChanged: (_) =>
                            controller.toggleLock(app.packageName),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PinSetupPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pin_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Set a PIN to start locking apps',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.pinSetup),
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }
}

class _OverlayPermissionPrompt extends StatelessWidget {
  final AppLockController controller;

  const _OverlayPermissionPrompt({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Allow "Display over other apps" so the lock screen can appear',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await controller.openOverlaySettings();
              await controller.refreshPermissionStatus();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }
}
