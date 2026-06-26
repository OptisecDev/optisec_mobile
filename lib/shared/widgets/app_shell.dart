import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../features/cyber_academy/views/cyber_academy_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/privacy_guard/views/privacy_guard_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/wifi_shield/views/wifi_shield_view.dart';

class AppShell extends GetView<HomeController> {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DashboardView(),
            WifiShieldView(),
            PrivacyGuardView(),
            CyberAcademyView(),
            SettingsView(),
          ],
        ),
      ),
      bottomNavigationBar: _ShellNavBar(controller: controller),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────

class _ShellNavBar extends StatelessWidget {
  final HomeController controller;
  const _ShellNavBar({required this.controller});

  static const _tabs = [
    _TabDef(
      activeIcon: Icons.dashboard_rounded,
      inactiveIcon: Icons.dashboard_outlined,
      label: 'Dashboard',
      color: AppColors.primary,
    ),
    _TabDef(
      activeIcon: Icons.wifi_rounded,
      inactiveIcon: Icons.wifi_outlined,
      label: 'WiFi Shield',
      color: AppColors.info,
    ),
    _TabDef(
      activeIcon: Icons.shield_rounded,
      inactiveIcon: Icons.shield_outlined,
      label: 'Privacy',
      color: AppColors.primary,
    ),
    _TabDef(
      activeIcon: Icons.school_rounded,
      inactiveIcon: Icons.school_outlined,
      label: 'Academy',
      color: AppColors.warning,
    ),
    _TabDef(
      activeIcon: Icons.settings_rounded,
      inactiveIcon: Icons.settings_outlined,
      label: 'Settings',
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPad, top: 6),
        child: Obx(
          () => Row(
            children: _tabs.asMap().entries.map((e) {
              final idx = e.key;
              final tab = e.value;
              final active = controller.currentIndex.value == idx;
              return _NavItem(
                tab: tab,
                active: active,
                onTap: () => controller.navigateTo(idx),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Single nav item ───────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _TabDef tab;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated pill background
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? tab.color.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  active ? tab.activeIcon : tab.inactiveIcon,
                  color: active ? tab.color : AppColors.textDisabled,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? tab.color : AppColors.textDisabled,
                  height: 1,
                ),
                child: Text(tab.label),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab definition ────────────────────────────────────────────────

class _TabDef {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final Color color;

  const _TabDef({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.color,
  });
}
