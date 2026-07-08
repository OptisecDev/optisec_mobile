import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/services/password_vault_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/home/controllers/home_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';
import '../../../shared/models/security_score_model.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../threat_intel/controllers/threat_intel_controller.dart';
import '../../threat_intel/widgets/threat_alert_card.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/category_score_bar.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/score_breakdown_chart.dart';
import '../widgets/score_history_chart.dart';
import '../widgets/security_tip_card.dart';
import '../widgets/threat_item_card.dart';
import '../widgets/threat_timeline_chart.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ScoreHeroCard(controller: controller),
                const SizedBox(height: 20),
                _CategoryBreakdown(controller: controller),
                const SizedBox(height: 20),
                _StatsGrid(controller: controller),
                const SizedBox(height: 20),
                _QuickActions(controller: controller),
                const SizedBox(height: 20),
                const _ThreatIntelPreview(),
                const SizedBox(height: 20),
                _ChartsSection(controller: controller),
                const SizedBox(height: 20),
                _ThreatsSection(controller: controller),
                const SizedBox(height: 20),
                SecurityTipCard(controller: controller),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.security_rounded,
                color: AppColors.textOnPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('OptiSec', style: theme.textTheme.titleMedium),
              Obx(() => Text(
                    'Last scan: ${controller.lastScanLabel}',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  )),
            ],
          ),
        ],
      ),
      actions: [
        Obx(() {
          final count = controller.score.value.threatsDetected;
          return Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textSecondary,
                onPressed: () {},
              ),
              if (count > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          onPressed: () => Get.find<HomeController>().navigateTo(4),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── Hero Score Card ─────────────────────────────────────────────────────────

class _ScoreHeroCard extends StatelessWidget {
  final DashboardController controller;

  const _ScoreHeroCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final s = controller.score.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.primary.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            // Title row
            Row(
              children: [
                Text('Security Score',
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                if (s.scoreDelta != 0) _DeltaBadge(delta: s.scoreDelta),
              ],
            ),
            const SizedBox(height: 24),

            // Ring
            AnimatedScoreRing(
              key: ValueKey(s.overall),
              score: s.overall,
              size: 200,
              strokeWidth: 16,
            ),

            const SizedBox(height: 24),

            // Scan button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.runFullScan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: controller.isScanning.value
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : const Icon(Icons.radar_rounded, size: 19),
                    label: Text(
                      controller.isScanning.value
                          ? 'Scanning…'
                          : 'Run Full Scan',
                    ),
                  ),
                )),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms);
    });
  }
}

class _DeltaBadge extends StatelessWidget {
  final int delta;

  const _DeltaBadge({required this.delta});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? AppColors.safe : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            '${positive ? '+' : ''}$delta',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Breakdown ───────────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  final DashboardController controller;

  const _CategoryBreakdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final s = controller.score.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score Breakdown', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          CategoryScoreBar(
            label: 'WiFi Shield',
            score: s.wifiScore,
            icon: Icons.wifi_rounded,
            color: AppColors.info,
            index: 0,
          ),
          const SizedBox(height: 8),
          CategoryScoreBar(
            label: 'Privacy Guard',
            score: s.privacyScore,
            icon: Icons.privacy_tip_rounded,
            color: AppColors.primary,
            index: 1,
          ),
          const SizedBox(height: 8),
          CategoryScoreBar(
            label: 'App Security',
            score: s.appScore,
            icon: Icons.apps_rounded,
            color: AppColors.accent,
            index: 2,
          ),
        ],
      );
    });
  }
}

// ─── Stats 2×2 Grid ──────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardController controller;

  const _StatsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final s = controller.score.value;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _StatTile(
            theme: theme,
            icon: Icons.bug_report_rounded,
            label: 'Active Threats',
            value: '${s.threatsDetected}',
            color: s.threatsDetected > 0
                ? AppColors.danger
                : AppColors.safe,
            index: 0,
            onTap: () => Get.find<HomeController>().navigateTo(1),
          ),
          _StatTile(
            theme: theme,
            icon: Icons.wifi_tethering_rounded,
            label: 'Networks Scanned',
            value: '${s.networksScanned}',
            color: AppColors.info,
            index: 1,
            onTap: () => Get.find<HomeController>().navigateTo(1),
          ),
          _StatTile(
            theme: theme,
            icon: Icons.shield_rounded,
            label: 'Privacy Score',
            value: '${s.privacyScore}',
            color: AppColors.primary,
            index: 2,
            onTap: () => Get.find<HomeController>().navigateTo(2),
          ),
          _StatTile(
            theme: theme,
            icon: Icons.trending_up_rounded,
            label: 'Score Delta',
            value: '${s.scoreDelta >= 0 ? '+' : ''}${s.scoreDelta}',
            color: s.scoreDelta >= 0 ? AppColors.safe : AppColors.danger,
            index: 3,
          ),
        ],
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int index;
  final VoidCallback? onTap;

  const _StatTile({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                if (onTap != null)
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: AppColors.textDisabled),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 + index * 60))
        .fadeIn(duration: 350.ms)
        .scale(
            begin: const Offset(0.92, 0.92),
            duration: 350.ms,
            curve: Curves.easeOutBack);
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final DashboardController controller;

  const _QuickActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.wifi_find_rounded,
                label: 'WiFi\nShield',
                color: AppColors.primary,
                onTap: () => Get.find<HomeController>().navigateTo(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionButton(
                icon: Icons.shield_moon_rounded,
                label: 'Privacy\nGuard',
                color: AppColors.accent,
                onTap: () => Get.find<HomeController>().navigateTo(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionButton(
                icon: Icons.school_rounded,
                label: 'Cyber\nAcademy',
                color: AppColors.warning,
                onTap: () => Get.find<HomeController>().navigateTo(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: QuickActionButton(
                icon: Icons.key_rounded,
                label: AppLocalizations.of(context).vaultDashboardTileLabel,
                color: AppColors.accent,
                onTap: _openPasswordVault,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openPasswordVault() async {
    final initialized = await PasswordVaultService.instance.isVaultInitialized();
    if (!initialized) {
      Get.toNamed(AppRoutes.vaultSetup);
      return;
    }
    final unlocked = await PasswordVaultService.instance.isUnlocked();
    Get.toNamed(unlocked ? AppRoutes.vault : AppRoutes.vaultUnlock);
  }
}

// ─── Threat Intel Preview ──────────────────────────────────────────────────

class _ThreatIntelPreview extends StatelessWidget {
  const _ThreatIntelPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intel = Get.find<ThreatIntelController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Latest Threat Intel', style: theme.textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.threatIntel),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            if (intel.isLoading.value && intel.alerts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final top = intel.topAlert;
            if (top == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active alerts',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textDisabled),
                ),
              );
            }

            return ThreatAlertCard(alert: top, index: 0);
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }
}

// ─── Charts Section ───────────────────────────────────────────────────────────

class _ChartsSection extends StatelessWidget {
  final DashboardController controller;

  const _ChartsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab selector
          Obx(() => Row(
                children: [
                  _ChartTab(
                    label: '7-Day History',
                    active: controller.selectedChartTab.value == 0,
                    onTap: () => controller.setChartTab(0),
                  ),
                  const SizedBox(width: 6),
                  _ChartTab(
                    label: 'Breakdown',
                    active: controller.selectedChartTab.value == 1,
                    onTap: () => controller.setChartTab(1),
                  ),
                  const SizedBox(width: 6),
                  _ChartTab(
                    label: 'Threats',
                    active: controller.selectedChartTab.value == 2,
                    onTap: () => controller.setChartTab(2),
                  ),
                ],
              )),

          const SizedBox(height: 18),

          // Chart content
          SizedBox(
            height: 200,
            child: Obx(() {
              switch (controller.selectedChartTab.value) {
                case 1:
                  return ScoreBreakdownChart(
                    key: const ValueKey('breakdown'),
                    wifiScore: controller.score.value.wifiScore,
                    privacyScore: controller.score.value.privacyScore,
                    appScore: controller.score.value.appScore,
                  ).animate().fadeIn(duration: 300.ms);
                case 2:
                  return ThreatTimelineChart(
                    key: const ValueKey('threats'),
                    threatCounts: controller.threatHistory,
                  ).animate().fadeIn(duration: 300.ms);
                default:
                  return ScoreHistoryChart(
                    key: const ValueKey('history'),
                    scores: controller.scoreHistory,
                  ).animate().fadeIn(duration: 300.ms);
              }
            }),
          ),

          // Legend line for history tab
          Obx(() {
            if (controller.selectedChartTab.value != 0) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  _legendDot(AppColors.safe, '≥ 80  Excellent'),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.primary, '60–79  Good'),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.warning, '40–59  Fair'),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(fontSize: 9.5, color: AppColors.textDisabled)),
      ],
    );
  }
}

class _ChartTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ChartTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}

// ─── Threats Section ──────────────────────────────────────────────────────────

class _ThreatsSection extends StatelessWidget {
  final DashboardController controller;

  const _ThreatsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final threats = controller.score.value.threats;
      if (threats.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Active Threats', style: theme.textTheme.titleMedium),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${threats.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.danger,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.find<HomeController>().navigateTo(1),
                child: const Text('View All',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...threats.asMap().entries.map(
                (e) =>
                    ThreatItemCard(threat: e.value, index: e.key),
              ),
        ],
      );
    });
  }
}
