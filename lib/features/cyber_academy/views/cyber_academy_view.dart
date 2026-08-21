import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/lesson_model.dart';
import '../controllers/cyber_academy_controller.dart';
import '../widgets/academy_hero_card.dart';
import '../widgets/featured_lesson_card.dart';
import '../widgets/lesson_card.dart';
import '../widgets/lesson_step_sheet.dart';

class CyberAcademyView extends GetView<CyberAcademyController> {
  const CyberAcademyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return _AcademyBody(controller: controller);
      }),
    );
  }
}

class _AcademyBody extends StatelessWidget {
  final CyberAcademyController controller;
  const _AcademyBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, l10n),
        SliverToBoxAdapter(child: _buildSearchBar(l10n)),
        SliverToBoxAdapter(child: const SizedBox(height: 20)),
        SliverToBoxAdapter(child: const AcademyHeroCard()),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverToBoxAdapter(child: _FeaturedSection(controller: controller)),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverToBoxAdapter(child: _CategoryFilterBar(controller: controller)),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),
        _LessonsSliver(controller: controller),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: Text(
        l10n.cyberAcademy,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Obx(() => controller.badges.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      l10n.cyberAcademyBadgesCount(controller.badges.length),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        onChanged: controller.setSearch,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: l10n.cyberAcademySearchHint,
          hintStyle: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textDisabled, size: 20),
          filled: true,
          fillColor: AppColors.card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  final CyberAcademyController controller;
  const _FeaturedSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final featured = controller.featuredLessons;
      if (featured.isEmpty) return const SizedBox.shrink();

      final continueLesson = controller.continueLessonCandidate;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  l10n.cyberAcademyFeaturedTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (continueLesson != null)
                  Text(
                    l10n.cyberAcademyContinueWhereLeftOff,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: continueLesson != null ? 240 : 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: featured.length,
              itemBuilder: (context, i) {
                final lesson = featured[i];
                final isContinue = lesson.id == continueLesson?.id;
                return FeaturedLessonCard(
                  lesson: lesson,
                  isContinue: isContinue,
                  onTap: () => LessonStepSheet.show(context, lesson),
                )
                    .animate(delay: Duration(milliseconds: i * 80))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0, duration: 400.ms);
              },
            ),
          ),
        ],
      );
    });
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final CyberAcademyController controller;
  const _CategoryFilterBar({required this.controller});

  List<(LessonCategory?, String, IconData)> _categories(AppLocalizations l10n) => [
        (null, l10n.cyberAcademyCategoryAll, Icons.apps_rounded),
        (LessonCategory.phishing, l10n.cyberAcademyCategoryPhishing,
            Icons.phishing_rounded),
        (LessonCategory.password, l10n.cyberAcademyCategoryPassword,
            Icons.lock_rounded),
        (LessonCategory.network, l10n.cyberAcademyCategoryNetwork,
            Icons.wifi_rounded),
        (LessonCategory.privacy, l10n.navPrivacy, Icons.shield_rounded),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final selected = controller.selectedCategory.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: _categories(l10n).map((item) {
            final (cat, label, icon) = item;
            final active = selected == cat;
            final color = _catColor(cat);
            return GestureDetector(
              onTap: () => controller.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? color.withValues(alpha: 0.15) : AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: active ? color : AppColors.cardBorder,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14,
                        color: active ? color : AppColors.textDisabled),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Color _catColor(LessonCategory? cat) {
    if (cat == null) return AppColors.primary;
    switch (cat) {
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
}

class _LessonsSliver extends StatelessWidget {
  final CyberAcademyController controller;
  const _LessonsSliver({required this.controller});

  String _sectionTitle(
    AppLocalizations l10n,
    LessonCategory? cat,
    String query,
  ) {
    if (cat != null) {
      switch (cat) {
        case LessonCategory.phishing:
          return l10n.cyberAcademySectionPhishingLessons;
        case LessonCategory.password:
          return l10n.cyberAcademySectionPasswordLessons;
        case LessonCategory.network:
          return l10n.cyberAcademySectionNetworkLessons;
        case LessonCategory.privacy:
          return l10n.cyberAcademySectionPrivacyLessons;
      }
    }
    return query.isNotEmpty
        ? l10n.cyberAcademySectionSearchResults
        : l10n.cyberAcademySectionAllLessons;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final list = controller.filteredLessons;
      final query = controller.searchQuery.value.trim();
      final cat = controller.selectedCategory.value;

      final sectionTitle = _sectionTitle(l10n, cat, query);

      if (list.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded,
                    color: AppColors.textDisabled, size: 40),
                const SizedBox(height: 12),
                Text(
                  l10n.cyberAcademyNoLessonsFound,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (query.isNotEmpty)
                  Text(
                    l10n.cyberAcademySearchResultsFor(query),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDisabled,
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${list.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...list.asMap().entries.map((e) => LessonCard(
                  lesson: e.value,
                  index: e.key,
                  onTap: () =>
                      LessonStepSheet.show(context, e.value),
                )),
          ]),
        ),
      );
    });
  }
}
