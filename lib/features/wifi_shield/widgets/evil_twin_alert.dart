import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/wifi_network_model.dart';

class EvilTwinAlert extends StatelessWidget {
  final List<WifiNetworkModel> evilTwins;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;

  const EvilTwinAlert({
    super.key,
    required this.evilTwins,
    required this.onDismiss,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Every evil twin carries either ThreatLevel.danger (a high-confidence
    // signal fired — see wifi_shield_controller's `_ouiMismatchConfidence`/
    // `forceDanger`) or ThreatLevel.warning (medium-confidence OUI mismatch
    // alone). Split into two groups so a mixed scan doesn't either water
    // down the real attack banner or scare the user over a likely mesh node.
    final highTwins =
        evilTwins.where((e) => e.threatLevel == ThreatLevel.danger).toList();
    final mediumTwins =
        evilTwins.where((e) => e.threatLevel != ThreatLevel.danger).toList();

    return Column(
      children: [
        if (highTwins.isNotEmpty)
          _EvilTwinBanner(
            twins: highTwins,
            highConfidence: true,
            onDismiss: onDismiss,
            onViewDetails: onViewDetails,
          ),
        if (mediumTwins.isNotEmpty)
          _EvilTwinBanner(
            twins: mediumTwins,
            highConfidence: false,
            onDismiss: onDismiss,
            onViewDetails: onViewDetails,
          ),
      ],
    );
  }
}

class _EvilTwinBanner extends StatelessWidget {
  final List<WifiNetworkModel> twins;
  final bool highConfidence;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;

  const _EvilTwinBanner({
    required this.twins,
    required this.highConfidence,
    required this.onDismiss,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ssids = twins.map((e) => '"${e.ssid}"').toSet().join(', ');
    final accentColor = highConfidence ? AppColors.danger : AppColors.warning;
    final title = highConfidence
        ? l10n.wifiEvilTwinDetectedTitle
        : l10n.wifiEvilTwinPossibleTitle;
    final body = highConfidence
        ? l10n.wifiEvilTwinBody(twins.length, ssids)
        : l10n.wifiEvilTwinPossibleBody(twins.length, ssids);
    final confidenceLabel = highConfidence
        ? l10n.wifiEvilTwinConfidenceHigh
        : l10n.wifiEvilTwinConfidenceMedium;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.18),
            accentColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Pulsing icon
                _PulsingIcon(color: accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    confidenceLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close_rounded,
                      color: accentColor.withOpacity(0.7), size: 18),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Reason chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _collectReasons(twins)
                      .map((r) => _reasonChip(l10n, r, accentColor))
                      .toList(),
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onDismiss,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.wifiDismiss,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: onViewDetails,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                l10n.wifiViewThreats,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Set<EvilTwinReason> _collectReasons(List<WifiNetworkModel> twins) {
    return twins.expand((t) => t.evilTwinReasons).toSet();
  }

  Widget _reasonChip(AppLocalizations l10n, EvilTwinReason reason, Color color) {
    final label = switch (reason) {
      EvilTwinReason.differentOui => l10n.wifiReasonVendorMismatch,
      EvilTwinReason.securityDowngrade => l10n.wifiReasonSecurityDowngrade,
      EvilTwinReason.signalAnomaly => l10n.wifiReasonSignalAnomaly,
      EvilTwinReason.openImpersonation => l10n.wifiReasonOpenImpersonation,
      EvilTwinReason.historicalBssidChange => l10n.wifiReasonBssidChanged,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final Color color;

  const _PulsingIcon({required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.gpp_bad_rounded, color: widget.color, size: 16),
      ),
    );
  }
}
