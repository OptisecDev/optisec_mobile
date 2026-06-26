import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _SettingsAppBar(),
          SliverToBoxAdapter(child: _AppHeaderCard()),
          SliverToBoxAdapter(child: const SizedBox(height: 8)),

          // Appearance
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              delay: 0,
            ),
          ),
          SliverToBoxAdapter(child: _AppearanceSection()),

          // Scanning
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.radar_rounded,
              title: 'Security Scanning',
              delay: 50,
            ),
          ),
          SliverToBoxAdapter(child: _ScanningSection()),

          // Notifications
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              delay: 100,
            ),
          ),
          SliverToBoxAdapter(child: _NotificationsSection()),

          // Privacy & Lock
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy & Lock',
              delay: 150,
            ),
          ),
          SliverToBoxAdapter(child: _PrivacySection()),

          // About
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.info_outline_rounded,
              title: 'About',
              delay: 200,
            ),
          ),
          SliverToBoxAdapter(child: _AboutSection()),

          // Danger zone
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.warning_amber_rounded,
              title: 'Data',
              titleColor: AppColors.danger,
              delay: 250,
            ),
          ),
          SliverToBoxAdapter(child: _DangerSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────
class _SettingsAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── App header card ──────────────────────────────────────────────
class _AppHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2440), Color(0xFF0A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // App icon placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF00A8D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.security_rounded,
                color: Colors.black, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OptiSec',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'v${c.appVersion} (Build ${c.buildNumber})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'All systems protected',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.safe,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms);
  }
}

// ── Section header ───────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final int delay;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: color,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms);
  }
}

// ── Appearance ───────────────────────────────────────────────────
class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return _SettingsGroup(
      delay: 50,
      children: [
        Obx(() => _ArrowTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.info,
              title: 'Language',
              subtitle: 'App display language',
              value: c.language.value == 'ar' ? 'العربية' : 'English',
              onTap: () => _showLanguageSheet(context, c),
            )),
        _Divider(),
        _StaticTile(
          icon: Icons.dark_mode_rounded,
          iconColor: const Color(0xFF8B5CF6),
          title: 'Theme',
          subtitle: 'Display theme',
          value: 'Dark',
        ),
      ],
    );
  }

  void _showLanguageSheet(BuildContext context, SettingsController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguageSheet(controller: c),
    );
  }
}

// ── Scanning ─────────────────────────────────────────────────────
class _ScanningSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return _SettingsGroup(
      delay: 100,
      children: [
        Obx(() => _SwitchTile(
              icon: Icons.radar_rounded,
              iconColor: AppColors.primary,
              title: 'Auto Scan',
              subtitle: 'Periodically scan for threats',
              value: c.autoScan.value,
              onChanged: (v) => c.autoScan.value = v,
            )),
        _Divider(),
        Obx(() => _ArrowTile(
              icon: Icons.timer_outlined,
              iconColor: AppColors.warning,
              title: 'Scan Interval',
              subtitle: 'How often to run auto scans',
              value: c.scanIntervalLabel,
              onTap: c.autoScan.value
                  ? () => _showIntervalSheet(context, c)
                  : null,
              dimmed: !c.autoScan.value,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.wifi_tethering_error_rounded,
              iconColor: AppColors.danger,
              title: 'Evil Twin Alerts',
              subtitle: 'Warn when a rogue access point is detected',
              value: c.evilTwinAlerts.value,
              onChanged: (v) => c.evilTwinAlerts.value = v,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.vpn_lock_rounded,
              iconColor: AppColors.info,
              title: 'VPN Detection',
              subtitle: 'Detect active VPN connections',
              value: c.vpnDetection.value,
              onChanged: (v) => c.vpnDetection.value = v,
            )),
      ],
    );
  }

  void _showIntervalSheet(BuildContext context, SettingsController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _IntervalSheet(controller: c),
    );
  }
}

// ── Notifications ────────────────────────────────────────────────
class _NotificationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return _SettingsGroup(
      delay: 150,
      children: [
        Obx(() => _SwitchTile(
              icon: Icons.notifications_rounded,
              iconColor: AppColors.primary,
              title: 'Push Notifications',
              subtitle: 'Allow OptiSec to send notifications',
              value: c.pushNotifications.value,
              onChanged: (v) => c.pushNotifications.value = v,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.warning_rounded,
              iconColor: AppColors.danger,
              title: 'Threat Alerts',
              subtitle: 'Immediate alerts for detected threats',
              value: c.threatAlerts.value,
              onChanged: c.pushNotifications.value
                  ? (v) => c.threatAlerts.value = v
                  : null,
              dimmed: !c.pushNotifications.value,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.warning,
              title: 'Weekly Security Report',
              subtitle: 'Summary of threats and scans each week',
              value: c.weeklyReport.value,
              onChanged: c.pushNotifications.value
                  ? (v) => c.weeklyReport.value = v
                  : null,
              dimmed: !c.pushNotifications.value,
            )),
      ],
    );
  }
}

// ── Privacy & Lock ───────────────────────────────────────────────
class _PrivacySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return _SettingsGroup(
      delay: 200,
      children: [
        Obx(() => _SwitchTile(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.primary,
              title: 'Biometric Lock',
              subtitle: 'Require fingerprint or Face ID to open app',
              value: c.biometricLock.value,
              onChanged: (v) => c.biometricLock.value = v,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.analytics_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Usage Analytics',
              subtitle: 'Share anonymous usage data to improve the app',
              value: c.analyticsEnabled.value,
              onChanged: (v) => c.analyticsEnabled.value = v,
            )),
      ],
    );
  }
}

// ── About ────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return _SettingsGroup(
      delay: 250,
      children: [
        _ArrowTile(
          icon: Icons.star_rate_rounded,
          iconColor: const Color(0xFFFFD700),
          title: 'Rate OptiSec',
          subtitle: 'Leave a review on the App Store',
          onTap: () => _snack('Opening App Store…'),
        ),
        _Divider(),
        _ArrowTile(
          icon: Icons.share_rounded,
          iconColor: AppColors.info,
          title: 'Share App',
          subtitle: 'Tell your friends about OptiSec',
          onTap: () => _snack('Opening share sheet…'),
        ),
        _Divider(),
        _ArrowTile(
          icon: Icons.privacy_tip_outlined,
          iconColor: AppColors.textSecondary,
          title: 'Privacy Policy',
          onTap: () => _snack('Opening Privacy Policy…'),
        ),
        _Divider(),
        _ArrowTile(
          icon: Icons.description_outlined,
          iconColor: AppColors.textSecondary,
          title: 'Terms of Service',
          onTap: () => _snack('Opening Terms of Service…'),
        ),
        _Divider(),
        _StaticTile(
          icon: Icons.build_circle_outlined,
          iconColor: AppColors.textDisabled,
          title: 'Version',
          value: 'v${c.appVersion} (${c.buildNumber})',
        ),
      ],
    );
  }

  void _snack(String msg) {
    Get.snackbar(
      '',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFFE8F4FD),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}

// ── Danger zone ──────────────────────────────────────────────────
class _DangerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return _SettingsGroup(
      delay: 300,
      borderColor: AppColors.danger.withOpacity(0.25),
      children: [
        _ActionTile(
          icon: Icons.history_rounded,
          iconColor: AppColors.warning,
          title: 'Clear Scan History',
          subtitle: 'Remove all saved scan results',
          actionLabel: 'Clear',
          actionColor: AppColors.warning,
          onTap: () => _confirmClear(context, c),
        ),
        _Divider(),
        Obx(() => _ActionTile(
              icon: Icons.delete_forever_rounded,
              iconColor: AppColors.danger,
              title: 'Reset All Data',
              subtitle: 'Erase everything and restore defaults',
              actionLabel:
                  c.isResetting.value ? 'Resetting…' : 'Reset',
              actionColor: AppColors.danger,
              onTap: c.isResetting.value
                  ? null
                  : () => _confirmReset(context, c),
              loading: c.isResetting.value,
            )),
      ],
    );
  }

  void _confirmClear(BuildContext context, SettingsController c) {
    _showConfirmDialog(
      context: context,
      title: 'Clear Scan History?',
      body: 'This will remove all saved scan results. Your settings will not be affected.',
      confirmLabel: 'Clear',
      confirmColor: AppColors.warning,
      onConfirm: c.clearScanHistory,
    );
  }

  void _confirmReset(BuildContext context, SettingsController c) {
    _showConfirmDialog(
      context: context,
      title: 'Reset All Data?',
      body:
          'This will erase all scan history, threat records, and restore all settings to their defaults. This cannot be undone.',
      confirmLabel: 'Reset Everything',
      confirmColor: AppColors.danger,
      onConfirm: c.resetAllData,
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE8F4FD),
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8DA3BC),
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8DA3BC))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              confirmLabel,
              style: TextStyle(
                  color: confirmColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared tile widgets ──────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final int delay;
  final Color? borderColor;

  const _SettingsGroup({
    required this.children,
    required this.delay,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: borderColor ?? AppColors.cardBorder),
      ),
      child: Column(children: children),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.04, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.cardBorder,
      indent: 56,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool dimmed;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = dimmed ? 0.4 : 1.0;
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDisabled,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
              inactiveTrackColor: AppColors.cardBorder,
              inactiveThumbColor: AppColors.textDisabled,
              trackOutlineColor:
                  WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool dimmed;

  const _ArrowTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          child: Row(
            children: [
              _IconBox(icon: icon, color: iconColor),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textDisabled,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String? value;

  const _StaticTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor ?? AppColors.textDisabled),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDisabled,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback? onTap;
  final bool loading;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.actionLabel,
    required this.actionColor,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: actionColor.withOpacity(0.3)),
              ),
              child: loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: actionColor,
                      ),
                    )
                  : Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: actionColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ── Language bottom sheet ────────────────────────────────────────

class _LanguageSheet extends StatelessWidget {
  final SettingsController controller;
  const _LanguageSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _LangOption(
            flag: '🇺🇸',
            label: 'English',
            sublabel: 'English',
            code: 'en',
            controller: controller,
          ),
          const SizedBox(height: 10),
          _LangOption(
            flag: '🇸🇦',
            label: 'العربية',
            sublabel: 'Arabic',
            code: 'ar',
            controller: controller,
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final String sublabel;
  final String code;
  final SettingsController controller;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.code,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.language.value == code;
      return GestureDetector(
        onTap: () {
          controller.setLanguage(code);
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.cardBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontFamily: code == 'ar' ? 'Cairo' : null,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20),
            ],
          ),
        ),
      );
    });
  }
}

// ── Interval bottom sheet ────────────────────────────────────────

class _IntervalSheet extends StatelessWidget {
  final SettingsController controller;
  const _IntervalSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Scan Interval',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How often should OptiSec scan for threats?',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 20),
          ...SettingsController.scanIntervals.map((minutes) {
            final label = minutes < 60
                ? 'Every $minutes minutes'
                : 'Every hour';
            final sublabel = minutes <= 10
                ? 'High frequency — more battery usage'
                : minutes <= 20
                    ? 'Balanced — recommended'
                    : 'Low frequency — minimal battery usage';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Obx(() {
                final selected =
                    controller.scanIntervalMinutes.value == minutes;
                return GestureDetector(
                  onTap: () {
                    controller.setScanInterval(minutes);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                sublabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}
