import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/privacy_guard_controller.dart';

/// Shows one currently-granted, risky [PermissionInfo] and lets the user
/// act on it. Driven entirely by the real permission scan (see
/// PrivacyGuardController.permissions) rather than a fixed list, so it only
/// ever shows permissions that are actually granted right now.
class PrivacyRecommendationCard extends StatelessWidget {
  final PermissionInfo permission;
  final int index;
  final VoidCallback onAction;

  const PrivacyRecommendationCard({
    super.key,
    required this.permission,
    required this.index,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = permission.riskColor(context);
    final name = permission.name(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(permission.icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.privacyRecGrantedTitle(name),
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 12)),
                          const SizedBox(height: 3),
                          Text(permission.description(context),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 11, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          l10n.privacyFix,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 70))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.05, end: 0, duration: 350.ms);
  }
}
