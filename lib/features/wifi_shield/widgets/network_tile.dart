import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/wifi_network_model.dart';
import 'network_detail_sheet.dart';
import 'risk_score_badge.dart';
import 'wifi_signal_bars.dart';

class NetworkTile extends StatelessWidget {
  final WifiNetworkModel network;
  final int index;

  const NetworkTile({super.key, required this.network, required this.index});

  Color get _borderColor {
    if (network.isEvilTwin) return AppColors.danger.withOpacity(0.5);
    if (network.isConnected) return AppColors.primary.withOpacity(0.4);
    if (network.threatLevel == ThreatLevel.warning) {
      return AppColors.warning.withOpacity(0.3);
    }
    return AppColors.cardBorder;
  }

  Color get _bgColor {
    if (network.isEvilTwin) return AppColors.danger.withOpacity(0.05);
    if (network.isConnected) return AppColors.primary.withOpacity(0.06);
    return AppColors.card;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => NetworkDetailSheet.show(context, network),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 1.2),
        ),
        child: Column(
          children: [
            // Evil Twin indicator strip
            if (network.isEvilTwin)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gpp_bad_rounded,
                        color: AppColors.danger, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'Evil Twin Detected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      network.evilTwinReasons
                          .map(_shortReason)
                          .join(' • '),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon + SSID + risk badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WifiSignalBars(
                          percent: network.signalPercent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              network.ssid,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: network.isEvilTwin
                                    ? AppColors.danger
                                    : network.isConnected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              network.bssid,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'monospace',
                                letterSpacing: 0.4,
                                fontSize: 9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      RiskScoreBadge(
                          score: network.riskScore, compact: true),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Signal bar
                  _SignalProgressBar(percent: network.signalPercent),

                  const SizedBox(height: 10),

                  // Metadata chips row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip(_securityIcon(network.security),
                            network.securityLabel,
                            _securityColor(network.security)),
                        const SizedBox(width: 6),
                        _chip(Icons.radio_rounded, network.band,
                            AppColors.textDisabled),
                        const SizedBox(width: 6),
                        _chip(Icons.signal_wifi_4_bar_rounded,
                            '${network.signalPercent}%',
                            AppColors.textDisabled),
                        const SizedBox(width: 6),
                        _chip(Icons.tune_rounded, 'Ch ${network.channel}',
                            AppColors.textDisabled),
                        if (network.isConnected) ...[
                          const SizedBox(width: 6),
                          _chip(Icons.check_circle_outline_rounded,
                              'Connected', AppColors.primary),
                        ],
                      ],
                    ),
                  ),

                  // Threat messages (collapsed to 2)
                  if (network.threats.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...network.threats.take(2).map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  network.isEvilTwin
                                      ? Icons.dangerous_rounded
                                      : Icons.warning_amber_rounded,
                                  color: network.isEvilTwin
                                      ? AppColors.danger
                                      : AppColors.warning,
                                  size: 12,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: network.isEvilTwin
                                          ? AppColors.danger
                                              .withOpacity(0.9)
                                          : AppColors.warning,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (network.threats.length > 2)
                      Text(
                        '+${network.threats.length - 2} more — tap to view',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 45))
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.06, end: 0, duration: 280.ms, curve: Curves.easeOut);
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _securityIcon(WifiSecurity s) {
    switch (s) {
      case WifiSecurity.open:
        return Icons.lock_open_rounded;
      case WifiSecurity.wep:
      case WifiSecurity.wpa:
        return Icons.lock_outline_rounded;
      case WifiSecurity.wpa2:
      case WifiSecurity.wpa3:
        return Icons.lock_rounded;
      case WifiSecurity.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color _securityColor(WifiSecurity s) {
    switch (s) {
      case WifiSecurity.open:
        return AppColors.danger;
      case WifiSecurity.wep:
        return AppColors.warning;
      case WifiSecurity.wpa:
        return AppColors.warning;
      case WifiSecurity.wpa2:
        return AppColors.safe;
      case WifiSecurity.wpa3:
        return AppColors.primary;
      case WifiSecurity.unknown:
        return AppColors.textDisabled;
    }
  }

  String _shortReason(EvilTwinReason r) {
    switch (r) {
      case EvilTwinReason.differentOui:
        return 'OUI Mismatch';
      case EvilTwinReason.securityDowngrade:
        return 'Downgrade';
      case EvilTwinReason.signalAnomaly:
        return 'Signal';
      case EvilTwinReason.openImpersonation:
        return 'Honeypot';
      case EvilTwinReason.historicalBssidChange:
        return 'BSSID Changed';
    }
  }
}

class _SignalProgressBar extends StatelessWidget {
  final int percent;

  const _SignalProgressBar({required this.percent});

  Color get _color {
    if (percent >= 70) return AppColors.safe;
    if (percent >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            Container(
              height: 4,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              height: 4,
              width: constraints.maxWidth * (percent / 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [_color.withOpacity(0.6), _color],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
