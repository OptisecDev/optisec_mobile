import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';

class SecurityTipCard extends StatefulWidget {
  final DashboardController controller;

  const SecurityTipCard({super.key, required this.controller});

  @override
  State<SecurityTipCard> createState() => _SecurityTipCardState();
}

class _SecurityTipCardState extends State<SecurityTipCard> {
  final _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.controller.tipCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.accent.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Security Tip',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Dot indicators
                Row(
                  children: List.generate(count, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 4),
                      width: i == _current ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _current
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Page content
          SizedBox(
            height: 96,
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: count,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) {
                final tip = widget.controller.tipAt(i);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          IconData(tip.icon, fontFamily: 'MaterialIcons'),
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11.5,
                                height: 1.45,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }
}
