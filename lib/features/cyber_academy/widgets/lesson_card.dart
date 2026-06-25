import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.index,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (lesson.category) {
      case LessonCategory.phishing:
        return AppColors.danger;
      case LessonCategory.password:
        return AppColors.warning;
      case LessonCategory.network:
        return AppColors.info;
      case LessonCategory.privacy:
        return AppColors.primary;
    }
  }

  IconData get _categoryIcon {
    switch (lesson.category) {
      case LessonCategory.phishing:
        return Icons.phishing_rounded;
      case LessonCategory.password:
        return Icons.lock_rounded;
      case LessonCategory.network:
        return Icons.wifi_rounded;
      case LessonCategory.privacy:
        return Icons.shield_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = lesson.status == LessonStatus.completed;
    final isInProgress = lesson.status == LessonStatus.inProgress;

    Color statusColor = isCompleted
        ? AppColors.safe
        : isInProgress
            ? AppColors.warning
            : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.safe.withOpacity(0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Category stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.safe : _categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(_categoryIcon,
                                      color: _categoryColor, size: 21),
                                ),
                                if (isCompleted)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.safe,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.card, width: 1.5),
                                      ),
                                      child: const Icon(Icons.check_rounded,
                                          color: Colors.black, size: 9),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Titles
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesson.titleEn,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  lesson.titleAr,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppColors.textDisabled,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Status chip
                          _StatusChip(
                            status: lesson.status,
                            color: statusColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Meta row: difficulty + XP + duration + tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _MetaChip(
                            icon: _difficultyIcon(lesson.difficulty),
                            label: _difficultyLabel(lesson.difficulty),
                            color: _difficultyColor(lesson.difficulty),
                          ),
                          _MetaChip(
                            icon: Icons.star_rounded,
                            label: '${lesson.xpPoints} XP',
                            color: const Color(0xFFFFD700),
                          ),
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label: '${lesson.durationMinutes} min',
                            color: AppColors.textDisabled,
                          ),
                          if (lesson.steps.isNotEmpty)
                            _MetaChip(
                              icon: Icons.layers_rounded,
                              label: '${lesson.steps.length} steps',
                              color: AppColors.textDisabled,
                            ),
                        ],
                      ),

                      // Progress bar
                      if (isInProgress || isCompleted) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: lesson.progressPercent / 100,
                                  minHeight: 5,
                                  backgroundColor: AppColors.cardBorder,
                                  valueColor:
                                      AlwaysStoppedAnimation(statusColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${lesson.progressPercent}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 55))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.06, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  IconData _difficultyIcon(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return Icons.sentiment_satisfied_alt_rounded;
      case Difficulty.intermediate:
        return Icons.trending_up_rounded;
      case Difficulty.advanced:
        return Icons.local_fire_department_rounded;
    }
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  Color _difficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return AppColors.safe;
      case Difficulty.intermediate:
        return AppColors.warning;
      case Difficulty.advanced:
        return AppColors.danger;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final LessonStatus status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = status == LessonStatus.completed
        ? '✓ Done'
        : status == LessonStatus.inProgress
            ? 'Continue'
            : 'Start';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
