import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/lesson_model.dart';
import '../controllers/cyber_academy_controller.dart';

class LessonStepSheet extends StatelessWidget {
  const LessonStepSheet({super.key});

  static void show(BuildContext context, LessonModel lesson) {
    final c = Get.find<CyberAcademyController>();
    c.startLesson(lesson);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LessonStepSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CyberAcademyController>();
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Obx(() {
            final lesson = c.activeLesson.value;
            if (lesson == null) return const SizedBox.shrink();

            final stepIndex = c.activeStepIndex.value;
            final steps = lesson.steps;
            final hasSteps = steps.isNotEmpty;

            if (!hasSteps) {
              return _NoStepsBody(lesson: lesson, onClose: () {
                c.closeLesson();
                Navigator.pop(context);
              });
            }

            final step = steps[stepIndex];
            final progress = (stepIndex + 1) / steps.length;
            final isLast = stepIndex == steps.length - 1;

            return Column(
              children: [
                // Handle + header
                _SheetHeader(
                  lesson: lesson,
                  stepIndex: stepIndex,
                  totalSteps: steps.length,
                  progress: progress,
                  onClose: () {
                    c.closeLesson();
                    Navigator.pop(context);
                  },
                ),

                // Step body
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: step.isQuiz
                        ? _QuizStep(step: step)
                        : _InfoStep(step: step),
                  ),
                ),

                // Footer button
                _StepFooter(
                  step: step,
                  isLast: isLast,
                  onNext: () {
                    if (step.isQuiz && !c.quizAnswered.value) return;
                    if (isLast) {
                      c.nextStep();
                      Navigator.pop(context);
                    } else {
                      c.nextStep();
                    }
                  },
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final LessonModel lesson;
  final int stepIndex;
  final int totalSteps;
  final double progress;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.lesson,
    required this.stepIndex,
    required this.totalSteps,
    required this.progress,
    required this.onClose,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.titleEn,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Step ${stepIndex + 1} of $totalSteps',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(stepIndex),
            tween: Tween(
              begin: stepIndex / totalSteps,
              end: progress,
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Stack(
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _InfoStep extends StatelessWidget {
  final LessonStep step;
  const _InfoStep({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            step.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.75,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizStep extends StatelessWidget {
  final LessonStep step;
  const _QuizStep({required this.step});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CyberAcademyController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quiz badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_rounded, size: 13, color: AppColors.accent),
              SizedBox(width: 5),
              Text(
                'KNOWLEDGE CHECK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),

        Obx(() {
          final answered = c.quizAnswered.value;
          final selected = c.selectedQuizOption.value;

          return Column(
            children: step.options.asMap().entries.map((e) {
              final idx = e.key;
              final option = e.value;
              final isSelected = selected == idx;
              final isCorrect = idx == step.correctIndex;

              Color borderColor = AppColors.cardBorder;
              Color bgColor = AppColors.card;
              Color textColor = AppColors.textPrimary;
              Widget? trailingIcon;

              if (answered) {
                if (isCorrect) {
                  borderColor = AppColors.safe;
                  bgColor = AppColors.safe.withOpacity(0.1);
                  textColor = AppColors.safe;
                  trailingIcon = const Icon(Icons.check_circle_rounded,
                      color: AppColors.safe, size: 18);
                } else if (isSelected) {
                  borderColor = AppColors.danger;
                  bgColor = AppColors.danger.withOpacity(0.08);
                  textColor = AppColors.danger;
                  trailingIcon = const Icon(Icons.cancel_rounded,
                      color: AppColors.danger, size: 18);
                }
              } else if (isSelected) {
                borderColor = AppColors.primary;
                bgColor = AppColors.primary.withOpacity(0.1);
              }

              return GestureDetector(
                onTap: answered ? null : () => c.answerQuiz(idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      // Index circle
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderColor.withOpacity(0.15),
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + idx),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: borderColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        trailingIcon,
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),

        Obx(() {
          if (!c.quizAnswered.value) return const SizedBox.shrink();
          final correct = c.isAnswerCorrect(step);
          return Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: correct
                  ? AppColors.safe.withOpacity(0.08)
                  : AppColors.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: correct
                      ? AppColors.safe.withOpacity(0.3)
                      : AppColors.danger.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  correct
                      ? Icons.emoji_events_rounded
                      : Icons.lightbulb_rounded,
                  color:
                      correct ? AppColors.safe : AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    correct
                        ? 'Correct! Well done.'
                        : 'Not quite — the correct answer is highlighted above.',
                    style: TextStyle(
                      fontSize: 13,
                      color: correct ? AppColors.safe : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StepFooter extends StatelessWidget {
  final LessonStep step;
  final bool isLast;
  final VoidCallback onNext;

  const _StepFooter({
    required this.step,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CyberAcademyController>();
    return Obx(() {
      final canProceed =
          !step.isQuiz || c.quizAnswered.value;

      return Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.cardBorder),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canProceed ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLast
                  ? const Color(0xFFFFD700)
                  : AppColors.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.cardBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLast
                      ? Icons.emoji_events_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isLast ? 'Complete Lesson' : 'Next Step',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NoStepsBody extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onClose;

  const _NoStepsBody({required this.lesson, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.construction_rounded,
              color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Content coming soon',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(lesson.descriptionEn,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onClose,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
