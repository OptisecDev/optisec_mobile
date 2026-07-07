import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_page_data.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: OnboardingController.totalPages,
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: kOnboardingPages[index],
                pageIndex: index,
              );
            },
          ),

          // Skip button (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Obx(() => AnimatedOpacity(
                  opacity: controller.isLastPage ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: controller.skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )),
          ),

          // Bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(),
          ),
        ],
      ),
    );
  }
}

// ── Single onboarding page ────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int pageIndex;

  const _OnboardingPage({required this.data, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Illustration area — top 52%
        SizedBox(
          height: size.height * 0.52,
          child: _IllustrationArea(data: data),
        ),

        // Content area
        Expanded(
          child: _ContentArea(data: data, pageIndex: pageIndex),
        ),
      ],
    );
  }
}

// ── Illustration with animated orbit ─────────────────────────────
class _IllustrationArea extends StatefulWidget {
  final OnboardingPageData data;
  const _IllustrationArea({required this.data});

  @override
  State<_IllustrationArea> createState() => _IllustrationAreaState();
}

class _IllustrationAreaState extends State<_IllustrationArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.data.color;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background radial gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.2),
                radius: 0.85,
                colors: [
                  color.withOpacity(0.10),
                  color.withOpacity(0.04),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        // Orbit rings (static, decorative)
        _Ring(radius: 130, color: color, opacity: 0.08),
        _Ring(radius: 95, color: color, opacity: 0.12),

        // Orbit items (animated rotation)
        AnimatedBuilder(
          animation: _orbit,
          builder: (_, __) {
            return SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: widget.data.orbitItems.map((item) {
                  const orbitRadius = 115.0;
                  final angle =
                      item.angle + _orbit.value * 2 * math.pi;
                  final x = orbitRadius * math.cos(angle);
                  final y = orbitRadius * math.sin(angle);
                  return Positioned(
                    left: 130 + x - 18,
                    top: 130 + y - 18,
                    child: _OrbitBubble(icon: item.icon, color: item.color),
                  );
                }).toList(),
              ),
            );
          },
        ),

        // Center icon container
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.25),
                color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(widget.data.icon, color: color, size: 52),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  final double radius;
  final Color color;
  final double opacity;
  const _Ring({required this.radius, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(opacity), width: 1),
      ),
    );
  }
}

class _OrbitBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _OrbitBubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ── Content area (title, description, features) ───────────────────
class _ContentArea extends StatelessWidget {
  final OnboardingPageData data;
  final int pageIndex;

  const _ContentArea({required this.data, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '0${pageIndex + 1} / 0${OnboardingController.totalPages}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: data.color,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 14),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 450.ms)
              .slideY(begin: 0.15, end: 0, delay: 150.ms, duration: 450.ms),

          // Arabic title
          Text(
            data.titleAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textDisabled,
              height: 1.5,
            ),
            textDirection: TextDirection.rtl,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 12),

          // Description
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 450.ms),

          const SizedBox(height: 20),

          // Feature list
          ...data.features.asMap().entries.map((e) {
            final delay = Duration(milliseconds: 320 + e.key * 80);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child:
                        Icon(e.value.icon, color: data.color, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e.value.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: delay, duration: 350.ms)
                  .slideX(begin: 0.08, end: 0, delay: delay, duration: 350.ms),
            );
          }),
        ],
      ),
    );
  }
}

// ── Bottom bar (dots + buttons) ───────────────────────────────────
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<OnboardingController>();
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.background],
          stops: [0.0, 0.35],
        ),
      ),
      child: Row(
        children: [
          // Page dots
          Obx(() => _PageDots(
                count: OnboardingController.totalPages,
                current: c.currentPage.value,
                onTap: c.goToPage,
              )),

          const Spacer(),

          // Next / Get Started button
          Obx(() {
            final isLast = c.isLastPage;
            final pageData = kOnboardingPages[c.currentPage.value];
            return _NextButton(
              label: isLast ? 'Get Started' : 'Next',
              color: pageData.color,
              isLast: isLast,
              onTap: c.nextPage,
            );
          }),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  final void Function(int) onTap;

  const _PageDots({
    required this.count,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        final color = kOnboardingPages[current].color;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.only(right: 6),
            width: active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? color : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isLast;
  final VoidCallback onTap;

  const _NextButton({
    required this.label,
    required this.color,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isLast ? 28 : 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isLast
                  ? Icons.rocket_launch_rounded
                  : Icons.arrow_forward_rounded,
              color: Colors.black,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
