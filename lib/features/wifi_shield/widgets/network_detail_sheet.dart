import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/wifi_network_model.dart';
import '../../../shared/widgets/threat_badge.dart';
import 'risk_score_badge.dart';
import 'wifi_signal_bars.dart';

class NetworkDetailSheet extends StatelessWidget {
  final WifiNetworkModel network;

  const NetworkDetailSheet({super.key, required this.network});

  static void show(BuildContext context, WifiNetworkModel network) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NetworkDetailSheet(network: network),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    if (network.isEvilTwin) ...[
                      _buildEvilTwinSection(theme),
                      const SizedBox(height: 20),
                    ],
                    _buildDetailsGrid(theme),
                    const SizedBox(height: 20),
                    if (network.threats.isNotEmpty) _buildThreatsSection(theme),
                    const SizedBox(height: 20),
                    _buildRiskSection(theme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: network.isEvilTwin
                ? AppColors.danger.withOpacity(0.12)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: WifiSignalBars(percent: network.signalPercent, size: 26),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                network.ssid,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(network.bssid,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  ThreatBadge(level: network.threatLevel),
                  const SizedBox(width: 8),
                  if (network.isEvilTwin)
                    _dangerChip('Evil Twin'),
                  if (network.isConnected) ...[
                    const SizedBox(width: 8),
                    _connectedChip(),
                  ],
                ],
              ),
            ],
          ),
        ),
        RiskScoreBadge(score: network.riskScore),
      ],
    );
  }

  Widget _buildEvilTwinSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gpp_bad_rounded,
                  color: AppColors.danger, size: 16),
              const SizedBox(width: 8),
              Text(
                'Evil Twin Attack Indicators',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...network.evilTwinReasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded,
                        color: AppColors.danger, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _reasonDescription(r),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        _detailCell(theme, 'Security', network.securityLabel,
            Icons.lock_rounded),
        _detailCell(theme, 'Signal', '${network.level} dBm',
            Icons.signal_wifi_4_bar_rounded),
        _detailCell(theme, 'Band', network.band, Icons.radio_rounded),
        _detailCell(theme, 'Channel', '${network.channel}',
            Icons.tune_rounded),
        _detailCell(theme, 'Frequency', '${network.frequency} MHz',
            Icons.waves_rounded),
        _detailCell(theme, 'Vendor OUI', network.oui,
            Icons.device_hub_rounded),
      ],
    );
  }

  Widget _detailCell(
      ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detected Threats', style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        ...network.threats.map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(t,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskSection(ThemeData theme) {
    final segments = [
      ('Encryption', _encryptionRisk(), AppColors.warning),
      ('Evil Twin', network.isEvilTwin ? 60 : 0, AppColors.danger),
      ('Open Network', network.security == WifiSecurity.open ? 40 : 0,
          AppColors.danger),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Risk Breakdown', style: theme.textTheme.titleSmall),
            const Spacer(),
            RiskScoreBadge(score: network.riskScore),
          ],
        ),
        const SizedBox(height: 12),
        ...segments.where((s) => s.$2 > 0).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(s.$1, style: theme.textTheme.bodySmall),
                        const Spacer(),
                        Text('+${s.$2}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: s.$3)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.$2 / 100,
                        minHeight: 4,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: AlwaysStoppedAnimation(s.$3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  int _encryptionRisk() {
    switch (network.security) {
      case WifiSecurity.open:
        return 40;
      case WifiSecurity.wep:
        return 30;
      case WifiSecurity.wpa:
        return 10;
      default:
        return 0;
    }
  }

  String _reasonDescription(EvilTwinReason r) {
    switch (r) {
      case EvilTwinReason.differentOui:
        return 'Different hardware vendor broadcasting same SSID — OUI mismatch detected';
      case EvilTwinReason.securityDowngrade:
        return 'Weaker encryption than other APs with the same name — downgrade attack suspected';
      case EvilTwinReason.signalAnomaly:
        return 'Hidden network with abnormally strong signal suggests a rogue access point nearby';
      case EvilTwinReason.openImpersonation:
        return 'Open network impersonating a secured SSID — honeypot or captive portal attack';
    }
  }

  Widget _dangerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gpp_bad_rounded,
              color: AppColors.danger, size: 10),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _connectedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Connected',
        style: TextStyle(
            fontSize: 10,
            color: AppColors.primary,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
