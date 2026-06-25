import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/lesson_model.dart';

class FeaturedLessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onTap;
  final bool isContinue;

  const FeaturedLessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
    this.isContinue = false,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _categoryColor.withOpacity(0.18),
              AppColors.card,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _categoryColor.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            // Background watermark icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                _categoryIcon,
                size: 100,
                color: _categoryColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Continue / Featured badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isContinue
                              ? AppColors.primary.withOpacity(0.2)
                              : _categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isContinue ? 'CONTINUE' : 'FEATURED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isContinue
                                ? AppColors.primary
                                : _categoryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(_categoryIcon, color: _categoryColor, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    lesson.titleEn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.titleAr,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textDisabled,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),

                  // Progress bar (if in progress)
                  if (isContinue && lesson.progressPercent > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${lesson.progressPercent}% complete',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        Text(
                          '${lesson.xpPoints} XP',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: lesson.progressPercent / 100,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                  ] else ...[
                    // Meta chips
                    Wrap(
                      spacing: 6,
                      children: [
                        _meta(Icons.schedule_rounded,
                            '${lesson.durationMinutes} min'),
                        _meta(Icons.star_rounded,
                            '${lesson.xpPoints} XP',
                            color: const Color(0xFFFFD700)),
                        _meta(
                          _difficultyIcon(lesson.difficulty),
                          _difficultyLabel(lesson.difficulty),
                          color: _difficultyColor(lesson.difficulty),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Start / Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _categoryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isContinue ? 'Continue →' : 'Start Lesson →',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: c),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
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
