import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/wifi_shield_controller.dart';
import '../widgets/evil_twin_alert.dart';
import '../widgets/network_tile.dart';
import '../widgets/scan_radar.dart';
import '../widgets/wifi_signal_bars.dart';

class WifiShieldView extends GetView<WifiShieldController> {
  const WifiShieldView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (!controller.hasPermission.value) {
          return _PermissionView(onGrant: controller.requestPermission);
        }
        return _ShieldBody(controller: controller, theme: theme);
      }),
    );
  }
}

// ─── Permission Gate ─────────────────────────────────────────────────────────

class _PermissionView extends StatelessWidget {
  final VoidCallback onGrant;

  const _PermissionView({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WiFi Shield'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2), width: 2),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.primary, size: 42),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 28),
              Text('Location Permission Required',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 12),
              Text(
                'Android requires location access to scan nearby WiFi networks. OptiSec never uploads your location.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: onGrant,
                icon: const Icon(Icons.shield_rounded, size: 18),
                label: const Text('Grant Permission'),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main Body ───────────────────────────────────────────────────────────────

class _ShieldBody extends StatelessWidget {
  final WifiShieldController controller;
  final ThemeData theme;

  const _ShieldBody({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isScanning.value &&
            controller.networks.isEmpty) {
          return _ScanningView(controller: controller);
        }
        return _buildContent(context);
      }),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.wifi_find_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Text('WiFi Shield'),
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
                tooltip: 'Scan Again',
                onPressed: controller.startScan,
              )),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Evil Twin alert
              Obx(() {
                if (!controller.hasEvilTwin ||
                    controller.evilTwinDismissed.value) {
                  return const SizedBox();
                }
                return EvilTwinAlert(
                  evilTwins: controller.evilTwins,
                  onDismiss: controller.dismissEvilTwinAlert,
                  onViewDetails: () =>
                      controller.setFilter(FilterMode.evilTwin),
                );
              }),

              // Summary cards
              _SummaryRow(controller: controller),
              const SizedBox(height: 16),

              // Connected network card
              Obx(() {
                final ssid = controller.connectedSsid.value;
                if (ssid.isEmpty) return const SizedBox();
                return _ConnectedCard(controller: controller, theme: theme);
              }),

              // Filter & sort bar
              _FilterSortBar(controller: controller, theme: theme),
              const SizedBox(height: 16),

              // Networks list header
              Obx(() => Row(
                    children: [
                      Text(
                        controller.filterMode.value == FilterMode.all
                            ? 'Nearby Networks (${controller.networks.length})'
                            : _filterLabel(controller.filterMode.value,
                                controller.networks.length),
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (controller.isScanning.value)
                        const Text(
                          'Updating…',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textDisabled),
                        ),
                    ],
                  )),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // Network tiles
        Obx(() {
          if (controller.networks.isEmpty) {
            return SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      controller.filterMode.value == FilterMode.all
                          ? 'No networks found.\nTap the radar icon to scan.'
                          : 'No networks match this filter.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList.builder(
              itemCount: controller.networks.length,
              itemBuilder: (_, i) => NetworkTile(
                network: controller.networks[i],
                index: i,
              ),
            ),
          );
        }),
      ],
    );
  }

  String _filterLabel(FilterMode mode, int count) {
    switch (mode) {
      case FilterMode.safe:
        return 'Safe Networks ($count)';
      case FilterMode.threats:
        return 'Threats ($count)';
      case FilterMode.evilTwin:
        return 'Evil Twins ($count)';
      default:
        return 'Networks ($count)';
    }
  }
}

// ─── Scanning View ────────────────────────────────────────────────────────────

class _ScanningView extends StatelessWidget {
  final WifiShieldController controller;

  const _ScanningView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScanRadar(size: 200),
          const SizedBox(height: 32),
          Text('Scanning for networks…',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              )),
          const SizedBox(height: 8),
          Text(
            'Analyzing signals and detecting threats',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Summary Row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final WifiShieldController controller;

  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() => Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Safe',
                value: '${controller.safeCount}',
                icon: Icons.verified_rounded,
                color: AppColors.safe,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Threats',
                value: '${controller.threatCount}',
                icon: Icons.warning_amber_rounded,
                color: controller.threatCount > 0
                    ? AppColors.warning
                    : AppColors.textDisabled,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Evil Twins',
                value: '${controller.evilTwinCount}',
                icon: Icons.gpp_bad_rounded,
                color: controller.evilTwinCount > 0
                    ? AppColors.danger
                    : AppColors.textDisabled,
                theme: theme,
                pulse: controller.evilTwinCount > 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Total',
                value:
                    '${controller.networks.isEmpty ? 0 : controller.networks.length}',
                icon: Icons.wifi_tethering_rounded,
                color: AppColors.primary,
                theme: theme,
              ),
            ),
          ],
        ));
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool pulse;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withOpacity(0.7),
              )),
        ],
      ),
    );

    if (pulse) {
      card = card
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1200.ms, color: color.withOpacity(0.15));
    }

    return card
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
  }
}

// ─── Connected Card ──────────────────────────────────────────────────────────

class _ConnectedCard extends StatelessWidget {
  final WifiShieldController controller;
  final ThemeData theme;

  const _ConnectedCard(
      {required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ssid = controller.connectedSsid.value;
      final ip = controller.connectedIp.value;
      final gateway = controller.connectedGateway.value;
      final connected = controller.connectedNetwork;
      final isRisky = connected?.threatLevel != ThreatLevel.safe;
      final primaryC = isRisky ? AppColors.warning : AppColors.primary;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryC.withOpacity(0.1),
              AppColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryC.withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryC.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: WifiSignalBars(
                  percent: connected?.signalPercent ?? 75,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Connected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primaryC,
                            fontWeight: FontWeight.w700,
                          )),
                      if (isRisky) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 12),
                        const SizedBox(width: 3),
                        Text('Risky Network',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(ssid,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (ip.isNotEmpty) ...[
                        const Icon(Icons.computer_rounded,
                            size: 11, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(ip,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 11)),
                      ],
                      if (gateway.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.router_rounded,
                            size: 11, color: AppColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(gateway,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (connected != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryC.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('RISK',
                        style: TextStyle(
                            fontSize: 9,
                            color: primaryC.withOpacity(0.7),
                            fontWeight: FontWeight.w600)),
                    Text(
                      '${connected.riskScore}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryC),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    });
  }
}

// ─── Filter & Sort Bar ────────────────────────────────────────────────────────

class _FilterSortBar extends StatelessWidget {
  final WifiShieldController controller;
  final ThemeData theme;

  const _FilterSortBar({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', FilterMode.all, Icons.apps_rounded),
                  const SizedBox(width: 8),
                  _filterChip('Safe', FilterMode.safe,
                      Icons.verified_rounded),
                  const SizedBox(width: 8),
                  _filterChip(
                      'Threats', FilterMode.threats, Icons.warning_rounded),
                  const SizedBox(width: 8),
                  _filterChip('Evil Twins', FilterMode.evilTwin,
                      Icons.gpp_bad_rounded,
                      dangerColor: controller.evilTwinCount > 0),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Sort row
            Row(
              children: [
                Text('Sort:',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.textDisabled)),
                const SizedBox(width: 8),
                _sortChip('Signal', SortMode.signal),
                const SizedBox(width: 6),
                _sortChip('Risk', SortMode.risk),
                const SizedBox(width: 6),
                _sortChip('Name', SortMode.name),
              ],
            ),
          ],
        ));
  }

  Widget _filterChip(String label, FilterMode mode, IconData icon,
      {bool dangerColor = false}) {
    final active = controller.filterMode.value == mode;
    final color = dangerColor
        ? AppColors.danger
        : active
            ? AppColors.primary
            : AppColors.textDisabled;

    return GestureDetector(
      onTap: () => controller.setFilter(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, SortMode mode) {
    final active = controller.sortMode.value == mode;
    return GestureDetector(
      onTap: () => controller.setSort(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder,
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
