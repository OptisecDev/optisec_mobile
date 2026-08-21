import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _SettingsAppBar(),
          SliverToBoxAdapter(child: _AppHeaderCard()),
          SliverToBoxAdapter(child: const SizedBox(height: 8)),

          // Subscription
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.workspace_premium_rounded,
              title: l10n.settingsSectionSubscription,
              delay: 0,
            ),
          ),
          SliverToBoxAdapter(child: _SubscriptionSection()),

          // Appearance
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.palette_outlined,
              title: l10n.settingsSectionAppearance,
              delay: 0,
            ),
          ),
          SliverToBoxAdapter(child: _AppearanceSection()),

          // Scanning
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.radar_rounded,
              title: l10n.settingsSectionScanning,
              delay: 50,
            ),
          ),
          SliverToBoxAdapter(child: _ScanningSection()),

          // Notifications
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              delay: 100,
            ),
          ),
          SliverToBoxAdapter(child: _NotificationsSection()),

          // Privacy & Lock
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.lock_outline_rounded,
              title: l10n.settingsSectionPrivacyLock,
              delay: 150,
            ),
          ),
          SliverToBoxAdapter(child: _PrivacySection()),

          // About
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.info_outline_rounded,
              title: l10n.about,
              delay: 200,
            ),
          ),
          SliverToBoxAdapter(child: _AboutSection()),

          // Danger zone
          SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.warning_amber_rounded,
              title: l10n.settingsSectionData,
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
    final l10n = AppLocalizations.of(context);
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Text(
        l10n.settings,
        style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                  color: AppColors.primary.withValues(alpha: 0.35),
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
                Obx(() => Text(
                      l10n.settingsVersionBuild(c.appVersion.value, c.buildNumber.value),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                    )),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.settingsAllSystemsProtected,
                    style: const TextStyle(
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

// ── Subscription ─────────────────────────────────────────────────
class _SubscriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SubscriptionController>();
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final subscription = c.subscription.value;
      final isPro = subscription.isPro;

      final String subtitle;
      if (!isPro) {
        subtitle = l10n.settingsFreePlanSubtitle;
      } else if (subscription.expiryDate == null) {
        subtitle = subscription.licenseeLabel != null
            ? l10n.settingsLifetimeLicenseWithLabel(subscription.licenseeLabel!)
            : l10n.settingsLifetimeLicense;
      } else {
        final expiry = subscription.expiryDate!.toLocal();
        subtitle = l10n.settingsValidUntil(
            '${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}');
      }

      return _SettingsGroup(
        delay: 0,
        children: [
          _ArrowTile(
            icon: Icons.workspace_premium_rounded,
            iconColor: isPro ? AppColors.primary : AppColors.textSecondary,
            title: isPro ? l10n.settingsProActive : l10n.settingsProInactive,
            subtitle: subtitle,
            value: isPro ? l10n.settingsProBadge : l10n.settingsFreeBadge,
            onTap: () => Get.toNamed(AppRoutes.licenseKeyEntry),
          ),
        ],
      );
    });
  }
}

// ── Appearance ───────────────────────────────────────────────────
class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      delay: 50,
      children: [
        Obx(() => _ArrowTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.info,
              title: l10n.language,
              subtitle: l10n.settingsLanguageSubtitle,
              value: c.language.value == 'ar' ? 'العربية' : 'English',
              onTap: () => _showLanguageSheet(context, c),
            )),
        _Divider(),
        _StaticTile(
          icon: Icons.dark_mode_rounded,
          iconColor: const Color(0xFF8B5CF6),
          title: l10n.settingsThemeTitle,
          subtitle: l10n.settingsThemeSubtitle,
          value: l10n.settingsThemeDark,
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
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      delay: 100,
      children: [
        Obx(() => _SwitchTile(
              icon: Icons.radar_rounded,
              iconColor: AppColors.primary,
              title: l10n.settingsAutoScanTitle,
              subtitle: l10n.settingsAutoScanSubtitle,
              value: c.autoScan.value,
              onChanged: (v) => c.autoScan.value = v,
            )),
        _Divider(),
        Obx(() => _ArrowTile(
              icon: Icons.timer_outlined,
              iconColor: AppColors.warning,
              title: l10n.settingsScanIntervalTitle,
              subtitle: l10n.settingsScanIntervalSubtitle,
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
              title: l10n.settingsEvilTwinAlertsTitle,
              subtitle: l10n.settingsEvilTwinAlertsSubtitle,
              value: c.evilTwinAlerts.value,
              onChanged: (v) => c.evilTwinAlerts.value = v,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.vpn_lock_rounded,
              iconColor: AppColors.info,
              title: l10n.settingsVpnDetectionTitle,
              subtitle: l10n.settingsVpnDetectionSubtitle,
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
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      delay: 150,
      children: [
        Obx(() => _SwitchTile(
              icon: Icons.notifications_rounded,
              iconColor: AppColors.primary,
              title: l10n.settingsPushNotifTitle,
              subtitle: l10n.settingsPushNotifSubtitle,
              value: c.pushNotifications.value,
              onChanged: (v) => c.pushNotifications.value = v,
            )),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.warning_rounded,
              iconColor: AppColors.danger,
              title: l10n.settingsThreatAlertsTitle,
              subtitle: l10n.settingsThreatAlertsSubtitle,
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
              title: l10n.settingsWeeklyReportTitle,
              subtitle: l10n.settingsWeeklyReportSubtitle,
              value: c.weeklyReport.value,
              onChanged: c.pushNotifications.value
                  ? (v) => c.setWeeklyReport(v)
                  : null,
              dimmed: !c.pushNotifications.value,
            )),
        _Divider(),
        Obx(() => _ActionTile(
              icon: Icons.picture_as_pdf_rounded,
              iconColor: AppColors.primary,
              title: l10n.settingsExportReportTitle,
              subtitle: l10n.settingsExportReportSubtitle,
              actionLabel: c.isExportingReport.value
                  ? l10n.settingsExportReportExportingAction
                  : l10n.settingsExportReportAction,
              actionColor: AppColors.primary,
              onTap: c.isExportingReport.value
                  ? null
                  : () => c.exportSecurityReport(),
              loading: c.isExportingReport.value,
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
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      delay: 200,
      children: [
        Obx(() => _SwitchTile(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.primary,
              title: l10n.settingsBiometricLockTitle,
              subtitle: l10n.settingsBiometricLockSubtitle,
              value: c.biometricLock.value,
              onChanged: (v) => c.biometricLock.value = v,
            )),
        _Divider(),
        _ArrowTile(
          icon: Icons.lock_person_rounded,
          iconColor: AppColors.primary,
          title: l10n.settingsAppLockTitle,
          subtitle: l10n.settingsAppLockSubtitle,
          onTap: () => Get.toNamed(AppRoutes.appLock),
        ),
        _Divider(),
        Obx(() => _SwitchTile(
              icon: Icons.analytics_outlined,
              iconColor: AppColors.textSecondary,
              title: l10n.settingsUsageAnalyticsTitle,
              subtitle: l10n.settingsUsageAnalyticsSubtitle,
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
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      delay: 250,
      children: [
        _ArrowTile(
          icon: Icons.star_rate_rounded,
          iconColor: const Color(0xFFFFD700),
          title: l10n.settingsRateAppTitle,
          subtitle: l10n.settingsRateAppSubtitle,
          onTap: () => _snack(l10n.settingsOpeningAppStore),
        ),
        _Divider(),
        _ArrowTile(
          icon: Icons.share_rounded,
          iconColor: AppColors.info,
          title: l10n.settingsShareAppTitle,
          subtitle: l10n.settingsShareAppSubtitle,
          onTap: () => _snack(l10n.settingsOpeningShareSheet),
        ),
        _Divider(),
        _ArrowTile(
          icon: Icons.privacy_tip_outlined,
          iconColor: AppColors.textSecondary,
          title: l10n.settingsPrivacyPolicy,
          onTap: () => _snack(l10n.settingsOpeningPrivacyPolicy),
        ),
        _Divider(),
        _ArrowTile(
          icon: Icons.description_outlined,
          iconColor: AppColors.textSecondary,
          title: l10n.settingsTermsOfService,
          onTap: () => _snack(l10n.settingsOpeningTerms),
        ),
        _Divider(),
        Obx(() => _StaticTile(
              icon: Icons.build_circle_outlined,
              iconColor: AppColors.textDisabled,
              title: l10n.version,
              value: l10n.settingsVersionShort(c.appVersion.value, c.buildNumber.value),
            )),
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
    final l10n = AppLocalizations.of(context);
    return _SettingsGroup(
      delay: 300,
      borderColor: AppColors.danger.withValues(alpha: 0.25),
      children: [
        _ActionTile(
          icon: Icons.history_rounded,
          iconColor: AppColors.warning,
          title: l10n.settingsClearHistoryTitle,
          subtitle: l10n.settingsClearHistorySubtitle,
          actionLabel: l10n.settingsClearAction,
          actionColor: AppColors.warning,
          onTap: () => _confirmClear(context, c, l10n),
        ),
        _Divider(),
        Obx(() => _ActionTile(
              icon: Icons.delete_forever_rounded,
              iconColor: AppColors.danger,
              title: l10n.settingsResetAllTitle,
              subtitle: l10n.settingsResetAllSubtitle,
              actionLabel: c.isResetting.value
                  ? l10n.settingsResettingAction
                  : l10n.settingsResetAction,
              actionColor: AppColors.danger,
              onTap: c.isResetting.value
                  ? null
                  : () => _confirmReset(context, c, l10n),
              loading: c.isResetting.value,
            )),
      ],
    );
  }

  void _confirmClear(
      BuildContext context, SettingsController c, AppLocalizations l10n) {
    _showConfirmDialog(
      context: context,
      title: l10n.settingsClearHistoryConfirmTitle,
      body: l10n.settingsClearHistoryConfirmBody,
      confirmLabel: l10n.settingsClearAction,
      confirmColor: AppColors.warning,
      cancelLabel: l10n.settingsCancel,
      onConfirm: c.clearScanHistory,
    );
  }

  void _confirmReset(
      BuildContext context, SettingsController c, AppLocalizations l10n) {
    _showConfirmDialog(
      context: context,
      title: l10n.settingsResetAllConfirmTitle,
      body: l10n.settingsResetAllConfirmBody,
      confirmLabel: l10n.settingsResetEverythingAction,
      confirmColor: AppColors.danger,
      cancelLabel: l10n.settingsCancel,
      onConfirm: c.resetAllData,
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required String cancelLabel,
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
            child: Text(cancelLabel,
                style: const TextStyle(color: Color(0xFF8DA3BC))),
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
              activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
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
                color: actionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: actionColor.withValues(alpha: 0.3)),
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
        color: color.withValues(alpha: 0.12),
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
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.settingsSelectLanguage,
            style: const TextStyle(
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
                ? AppColors.primary.withValues(alpha: 0.1)
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
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.settingsScanIntervalTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsScanIntervalPrompt,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 20),
          ...SettingsController.scanIntervals.map((minutes) {
            final label = minutes < 60
                ? l10n.settingsEveryMinutes(minutes)
                : l10n.settingsEveryHour;
            final sublabel = minutes <= 10
                ? l10n.settingsFreqHigh
                : minutes <= 20
                    ? l10n.settingsFreqBalanced
                    : l10n.settingsFreqLow;
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
                          ? AppColors.primary.withValues(alpha: 0.1)
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
