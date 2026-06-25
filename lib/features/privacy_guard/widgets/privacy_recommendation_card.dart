import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyRecommendation {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String action;

  const PrivacyRecommendation({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.action,
  });
}

const kPrivacyRecommendations = [
  PrivacyRecommendation(
    icon: Icons.mic_off_rounded,
    color: AppColors.danger,
    title: 'Restrict Microphone Access',
    body: 'You have 4 apps with permanent microphone access. Only voice/call apps need it.',
    action: 'Review Mic Apps',
  ),
  PrivacyRecommendation(
    icon: Icons.location_disabled_rounded,
    color: AppColors.warning,
    title: 'Use "While Using" for Location',
    body: 'Switch location permission from "Always" to "Only while using the app."',
    action: 'Update Location',
  ),
  PrivacyRecommendation(
    icon: Icons.people_outline_rounded,
    color: AppColors.warning,
    title: 'Limit Contacts Access',
    body: '5 apps can read your full contact list. Restrict to messaging apps only.',
    action: 'Review Contacts',
  ),
];

class PrivacyRecommendationCard extends StatelessWidget {
  final PrivacyRecommendation rec;
  final int index;
  final VoidCallback onAction;

  const PrivacyRecommendationCard({
    super.key,
    required this.rec,
    required this.index,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rec.color.withOpacity(0.25)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: rec.color,
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
                        color: rec.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(rec.icon, color: rec.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec.title,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 12)),
                          const SizedBox(height: 3),
                          Text(rec.body,
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
                          color: rec.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: rec.color.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Fix',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: rec.color,
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
