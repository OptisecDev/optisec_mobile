import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
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
    final theme = Theme.of(context);
    final ssids = evilTwins.map((e) => '"${e.ssid}"').toSet().join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.danger.withOpacity(0.18),
            AppColors.danger.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Pulsing icon
                _PulsingIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Evil Twin Attack Detected!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close_rounded,
                      color: AppColors.danger.withOpacity(0.7), size: 18),
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
                  '${evilTwins.length} rogue access ${evilTwins.length == 1 ? 'point' : 'points'} found impersonating $ssids',
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
                  children: _collectReasons(evilTwins)
                      .map((r) => _reasonChip(r))
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
                            'Dismiss',
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
                            color: AppColors.danger,
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
                                'View Threats',
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

  Widget _reasonChip(EvilTwinReason reason) {
    final label = switch (reason) {
      EvilTwinReason.differentOui => 'Vendor Mismatch',
      EvilTwinReason.securityDowngrade => 'Security Downgrade',
      EvilTwinReason.signalAnomaly => 'Signal Anomaly',
      EvilTwinReason.openImpersonation => 'Open Impersonation',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.danger.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.danger,
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
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
          color: AppColors.danger.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.gpp_bad_rounded,
            color: AppColors.danger, size: 16),
      ),
    );
  }
}
