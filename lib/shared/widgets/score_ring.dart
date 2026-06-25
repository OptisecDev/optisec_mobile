import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Animated arc ring that sweeps from 0 → [score] and counts the number up.
class AnimatedScoreRing extends StatelessWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final Duration duration;

  const AnimatedScoreRing({
    super.key,
    required this.score,
    this.size = 200,
    this.strokeWidth = 14,
    this.duration = const Duration(milliseconds: 1400),
  });

  Color _colorFor(int s) {
    if (s >= 80) return AppColors.safe;
    if (s >= 60) return AppColors.primary;
    if (s >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  String _statusFor(int s) {
    if (s >= 80) return 'Excellent';
    if (s >= 60) return 'Good';
    if (s >= 40) return 'Fair';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorFor(score);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedScore, _) {
        final displayScore = animatedScore.round();
        final progress = animatedScore / 100;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arc painter
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: progress,
                  color: color,
                  strokeWidth: strokeWidth,
                ),
              ),

              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayScore',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/100',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusFor(displayScore),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Keep old name available for any existing references
typedef ScoreRing = AnimatedScoreRing;

class _RingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double strokeWidth;

  // Arc spans 270° starting at 135° (bottom-left) going clockwise
  static const _startAngle = math.pi * 0.75;
  static const _totalSweep = math.pi * 1.5;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── Background track ────────────────────────────────────────────────
    final trackPaint = Paint()
      ..color = AppColors.cardBorder
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _totalSweep, false, trackPaint);

    // ── Tick marks ──────────────────────────────────────────────────────
    final tickPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const ticks = 10; // one per 10 score points
    for (int i = 1; i < ticks; i++) {
      final angle = _startAngle + (i / ticks) * _totalSweep;
      final inner = radius - strokeWidth * 0.6;
      final outer = radius + strokeWidth * 0.6;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
            center.dy + outer * math.sin(angle)),
        tickPaint,
      );
    }

    if (progress <= 0) return;
    final sweepAngle = _totalSweep * progress.clamp(0.0, 1.0);

    // ── Progress arc with sweep gradient ────────────────────────────────
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: _startAngle,
        endAngle: _startAngle + sweepAngle,
        colors: [color.withOpacity(0.5), color],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect, _startAngle, sweepAngle, false, progressPaint);

    // ── Glow dot at arc tip ─────────────────────────────────────────────
    final tipAngle = _startAngle + sweepAngle;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );

    // Outer glow blur
    canvas.drawCircle(
      tip,
      strokeWidth * 0.9,
      Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Bright center dot
    canvas.drawCircle(
      tip,
      strokeWidth * 0.38,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

/// Three-arc mini ring used in category breakdown rows.
class MiniScoreArc extends StatelessWidget {
  final int score;
  final Color color;
  final double size;

  const MiniScoreArc({
    super.key,
    required this.score,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (_, progress, __) => CustomPaint(
        size: Size(size, size),
        painter: _MiniArcPainter(progress: progress, color: color),
      ),
    );
  }
}

class _MiniArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniArcPainter({required this.progress, required this.color});

  static const _start = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      _start, _sweep, false,
      Paint()
        ..color = AppColors.cardBorder
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        _start, _sweep * progress, false,
        Paint()
          ..color = color
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniArcPainter old) =>
      old.progress != progress || old.color != color;
}
