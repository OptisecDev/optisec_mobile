import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated radar sweep shown while scanning.
class ScanRadar extends StatefulWidget {
  final double size;

  const ScanRadar({super.key, this.size = 180});

  @override
  State<ScanRadar> createState() => _ScanRadarState();
}

class _ScanRadarState extends State<ScanRadar> with TickerProviderStateMixin {
  late final AnimationController _sweepCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_sweepCtrl, _pulse]),
        builder: (_, __) {
          return CustomPaint(
            painter: _RadarPainter(
              sweepAngle: _sweepCtrl.value * 2 * math.pi,
              pulseScale: _pulse.value,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double sweepAngle;
  final double pulseScale;

  _RadarPainter({required this.sweepAngle, required this.pulseScale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // Concentric rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final r = maxR * (i / 4) * pulseScale;
      ringPaint.color = AppColors.primary.withOpacity(0.08 + i * 0.04);
      canvas.drawCircle(center, r, ringPaint);
    }

    // Cross-hairs
    final crossPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..strokeWidth = 0.8;
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), crossPaint);
    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), crossPaint);

    // Sweep gradient arc
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - 1.2,
        endAngle: sweepAngle,
        colors: [
          AppColors.primary.withOpacity(0.0),
          AppColors.primary.withOpacity(0.25),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxR));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxR * 0.95 * pulseScale),
      sweepAngle - 1.2,
      1.2,
      true,
      sweepPaint,
    );

    // Sweep leading edge line
    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final endX = center.dx + maxR * 0.95 * pulseScale * math.cos(sweepAngle);
    final endY = center.dy + maxR * 0.95 * pulseScale * math.sin(sweepAngle);
    canvas.drawLine(center, Offset(endX, endY), linePaint);

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.sweepAngle != sweepAngle || old.pulseScale != pulseScale;
}
