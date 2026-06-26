import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/score_ring.dart';
import '../controllers/privacy_guard_controller.dart';
import '../widgets/exposure_chart.dart';
import '../widgets/permission_tile.dart';
import '../widgets/privacy_recommendation_card.dart';

class PrivacyGuardView extends GetView<PrivacyGuardController> {
  const PrivacyGuardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingView();
        }
        return _ContentBody(controller: controller);
      }),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy Guard'), automaticallyImplyLeading: false),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Scanning permissions…',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  final PrivacyGuardController controller;

  const _ContentBody({required this.controller});

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
                _ScoreHero(controller: controller),
                const SizedBox(height: 20),
                _RiskSummaryRow(controller: controller),
                const SizedBox(height: 20),
                _DonutCard(controller: controller),
                const SizedBox(height: 20),
                _ExposureSection(controller: controller),
                const SizedBox(height: 20),
                _RecommendationsSection(controller: controller),
                const SizedBox(height: 20),
                _PermissionsSection(controller: controller),
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
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Privacy Guard'),
          Obx(() => Text(
                '${controller.highRiskCount} high-risk · '
                '${controller.grantedCount} granted',
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
              )),
        ],
      ),
      actions: [
        Obx(() => controller.isScanning.value
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.radar_rounded),
                color: AppColors.primary,
                onPressed: controller.runScan,
              )),
      ],
    );
  }
}

// ─── Score Hero ──────────────────────────────────────────────────────────────

class _ScoreHero extends StatelessWidget {
  final PrivacyGuardController controller;

  const _ScoreHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final score = controller.privacyScore.value;
      final Color accentColor = score >= 80
          ? AppColors.safe
          : score >= 60
              ? AppColors.primary
              : score >= 40
                  ? AppColors.warning
                  : AppColors.danger;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, accentColor.withOpacity(0.06)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            AnimatedScoreRing(
              key: ValueKey(score),
              score: score,
              size: 130,
              strokeWidth: 11,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Privacy Score',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    _scoreDesc(score),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  // Mini breakdown bullets
                  _bullet(theme, 'High risk',
                      controller.highRiskCount, AppColors.danger),
                  _bullet(theme, 'Medium risk',
                      controller.mediumRiskCount, AppColors.warning),
                  _bullet(theme, 'Protected',
                      controller.deniedCount, AppColors.safe),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 450.ms);
    });
  }

  String _scoreDesc(int score) {
    if (score >= 80) return 'Your privacy is well protected. Keep reviewing new app installs.';
    if (score >= 60) return 'Some permissions need attention. Review the recommendations below.';
    if (score >= 40) return 'Several high-risk permissions are active. Take action now.';
    return 'Critical privacy exposure detected. Revoke sensitive permissions immediately.';
  }

  Widget _bullet(ThemeData theme, String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
          const Spacer(),
          Text('$count',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ─── Risk Summary Row ─────────────────────────────────────────────────────────

class _RiskSummaryRow extends StatelessWidget {
  final PrivacyGuardController controller;

  const _RiskSummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() => Row(
          children: [
            Expanded(
              child: _SummaryCard(
                theme: theme,
                icon: Icons.dangerous_rounded,
                label: 'High Risk',
                value: '${controller.highRiskCount}',
                color: AppColors.danger,
                index: 0,
                onTap: () => controller.setFilter(PrivacyFilterMode.high),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                theme: theme,
                icon: Icons.warning_amber_rounded,
                label: 'Medium Risk',
                value: '${controller.mediumRiskCount}',
                color: AppColors.warning,
                index: 1,
                onTap: () => controller.setFilter(PrivacyFilterMode.medium),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                theme: theme,
                icon: Icons.verified_rounded,
                label: 'Protected',
                value: '${controller.deniedCount}',
                color: AppColors.safe,
                index: 2,
                onTap: () => controller.setFilter(PrivacyFilterMode.all),
              ),
            ),
          ],
        ));
  }
}

class _SummaryCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: color.withOpacity(0.7), fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 350.ms,
            curve: Curves.easeOutBack);
  }
}

// ─── Donut Risk Chart ─────────────────────────────────────────────────────────

class _DonutCard extends StatefulWidget {
  final PrivacyGuardController controller;

  const _DonutCard({required this.controller});

  @override
  State<_DonutCard> createState() => _DonutCardState();
}

class _DonutCardState extends State<_DonutCard> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Permission Risk Breakdown',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Obx(() {
            final high = widget.controller.highRiskCount;
            final medium = widget.controller.mediumRiskCount;
            final denied = widget.controller.deniedCount;
            final sections = <(double, Color, String)>[
              if (high > 0) (high.toDouble(), AppColors.danger, 'High'),
              if (medium > 0) (medium.toDouble(), AppColors.warning, 'Medium'),
              if (denied > 0) (denied.toDouble(), AppColors.safe, 'Safe'),
            ];
            if (sections.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No permission data yet.',
                      style: TextStyle(color: AppColors.textDisabled)),
                ),
              );
            }
            return SizedBox(
              height: 160,
              child: Row(
                children: [
                  // Donut chart
                  Expanded(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 44,
                        pieTouchData: PieTouchData(
                          touchCallback: (_, response) {
                            setState(() {
                              _touched = response?.touchedSection
                                  ?.touchedSectionIndex;
                            });
                          },
                        ),
                        sections: sections.asMap().entries.map((e) {
                          final isTouched = e.key == _touched;
                          final (value, color, _) = e.value;
                          return PieChartSectionData(
                            value: value,
                            color: color,
                            radius: isTouched ? 36 : 28,
                            showTitle: false,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Legend
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections.map((s) {
                        final (val, color, label) = s;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius:
                                        BorderRadius.circular(3)),
                              ),
                              const SizedBox(width: 8),
                              Text(label,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 11)),
                              const Spacer(),
                              Text(
                                '${val.toInt()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }
}

// ─── Exposure Section ─────────────────────────────────────────────────────────

class _ExposureSection extends StatelessWidget {
  final PrivacyGuardController controller;

  const _ExposureSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Data Exposure by Permission',
                  style: theme.textTheme.titleMedium),
              const Spacer(),
              Text('# apps granted',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.textDisabled, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => ExposureChart(permissions: controller.permissions.toList())),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms);
  }
}

// ─── Recommendations ─────────────────────────────────────────────────────────

class _RecommendationsSection extends StatelessWidget {
  final PrivacyGuardController controller;

  const _RecommendationsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.highRiskCount == 0 && controller.mediumRiskCount == 0) {
        return const SizedBox();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recommend_rounded,
                  color: AppColors.warning, size: 17),
              const SizedBox(width: 7),
              Text('Recommendations', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...kPrivacyRecommendations.asMap().entries.map(
                (e) => PrivacyRecommendationCard(
                  rec: e.value,
                  index: e.key,
                  onAction: controller.runScan,
                ),
              ),
        ],
      );
    });
  }
}

// ─── Permissions Section ──────────────────────────────────────────────────────

class _PermissionsSection extends StatelessWidget {
  final PrivacyGuardController controller;

  const _PermissionsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final list = controller.filteredPermissions;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + filter chips
          Text('App Permissions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          _FilterBar(controller: controller),
          const SizedBox(height: 14),

          // Tiles
          ...list.asMap().entries.map(
                (e) => PermissionTile(
                  permission: e.value,
                  index: e.key,
                  onRevoke: () => controller.revokePermission(e.value),
                ),
              ),

          if (list.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No permissions match this filter.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      );
    });
  }
}

class _FilterBar extends StatelessWidget {
  final PrivacyGuardController controller;

  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('All', PrivacyFilterMode.all,
                  controller.filterMode.value),
              const SizedBox(width: 7),
              _chip('Granted', PrivacyFilterMode.granted,
                  controller.filterMode.value),
              const SizedBox(width: 7),
              _chip('High Risk', PrivacyFilterMode.high,
                  controller.filterMode.value),
              const SizedBox(width: 7),
              _chip('Medium', PrivacyFilterMode.medium,
                  controller.filterMode.value),
            ],
          ),
        ));
  }

  Widget _chip(String label, PrivacyFilterMode mode,
      PrivacyFilterMode current) {
    final active = mode == current;
    final Color color = switch (mode) {
      PrivacyFilterMode.high => AppColors.danger,
      PrivacyFilterMode.medium => AppColors.warning,
      PrivacyFilterMode.granted => AppColors.info,
      _ => AppColors.primary,
    };
    return GestureDetector(
      onTap: () => controller.setFilter(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: active ? color : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? color : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
