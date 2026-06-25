import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle background grid
          Positioned.fill(child: _GridPainterWidget()),

          // Radial glow at center-top
          Positioned(
            top: size.height * 0.15,
            left: size.width / 2 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated rings + logo
                    _LogoStack(),
                    const SizedBox(height: 32),

                    // Brand name
                    const Text(
                      'OptiSec',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 600.ms),

                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Advanced Security Suite',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDisabled,
                        letterSpacing: 2.0,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 950.ms, duration: 500.ms),
                  ],
                ),
              ),

              // Loading area
              Expanded(
                flex: 2,
                child: _LoadingSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Animated rings + shield logo ─────────────────────────────────
class _LogoStack extends StatefulWidget {
  @override
  State<_LogoStack> createState() => _LogoStackState();
}

class _LogoStackState extends State<_LogoStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer scanning ring
          AnimatedBuilder(
            animation: _ring,
            builder: (_, __) => CustomPaint(
              size: const Size(180, 180),
              painter: _ScanRingPainter(_ring.value),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 700.ms)
              .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1),
                  delay: 200.ms, duration: 700.ms, curve: Curves.easeOutBack),

          // Mid ring (static, decorative)
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1),
                  delay: 300.ms, duration: 600.ms),

          // Logo container
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2440), Color(0xFF0A1830)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.primary,
              size: 46,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 700.ms)
              .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1),
                  delay: 400.ms, duration: 700.ms, curve: Curves.easeOutBack)
              // Subtle pulse after appearing
              .then(delay: 200.ms)
              .shimmer(
                duration: 1800.ms,
                color: AppColors.primary.withOpacity(0.25),
                angle: math.pi / 4,
              ),
        ],
      ),
    );
  }
}

class _ScanRingPainter extends CustomPainter {
  final double progress;
  _ScanRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Static outer ring
    final trackPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, trackPaint);

    // Sweeping arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          Colors.transparent,
          AppColors.primary.withOpacity(0.6),
          AppColors.primary,
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 0.95, 1.0],
        transform: GradientRotation(2 * math.pi * progress - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2 * math.pi * progress - math.pi / 2,
      1.2,
      false,
      sweepPaint,
    );

    // Bright dot at arc tip
    final angle = 2 * math.pi * progress - math.pi / 2 + 1.2;
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(dotX, dotY), 3.5, dotPaint);

    final dotPaintSolid = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(dotX, dotY), 1.5, dotPaintSolid);
  }

  @override
  bool shouldRepaint(_ScanRingPainter old) => old.progress != progress;
}

// ── Loading section ──────────────────────────────────────────────
class _LoadingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SplashController>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Thin separator
        Container(
          width: 40,
          height: 1,
          color: AppColors.cardBorder,
        )
            .animate()
            .fadeIn(delay: 1100.ms, duration: 400.ms)
            .scaleX(begin: 0, end: 1, delay: 1100.ms, duration: 400.ms),

        const SizedBox(height: 24),

        // Loading bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Obx(() => TweenAnimationBuilder<double>(
                key: ValueKey(c.loadingProgress.value),
                tween: Tween(
                  begin: (c.loadingProgress.value - 0.25).clamp(0.0, 1.0),
                  end: c.loadingProgress.value,
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => Stack(
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF00A8D4)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        )
            .animate()
            .fadeIn(delay: 1200.ms, duration: 400.ms),

        const SizedBox(height: 16),

        // Status text
        Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                c.statusText,
                key: ValueKey(c.statusIndex.value),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.3,
                ),
              ),
            ))
            .animate()
            .fadeIn(delay: 1300.ms, duration: 400.ms),

        const SizedBox(height: 32),

        // Version label
        const Text(
          'v1.0.0',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textDisabled,
          ),
        )
            .animate()
            .fadeIn(delay: 1400.ms, duration: 400.ms),
      ],
    );
  }
}

// ── Background grid painter ──────────────────────────────────────
class _GridPainterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
