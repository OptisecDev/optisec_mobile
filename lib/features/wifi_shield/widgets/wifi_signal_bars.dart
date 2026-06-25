import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Four-arc WiFi signal indicator mirroring the native icon style.
class WifiSignalBars extends StatelessWidget {
  final int percent; // 0–100
  final double size;

  const WifiSignalBars({super.key, required this.percent, this.size = 22});

  Color get _activeColor {
    if (percent >= 70) return AppColors.safe;
    if (percent >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  // Returns how many bars (1–4) are lit
  int get _bars {
    if (percent >= 75) return 4;
    if (percent >= 50) return 3;
    if (percent >= 25) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.75),
      painter: _SignalBarsPainter(
        litBars: _bars,
        activeColor: _activeColor,
        dimColor: AppColors.cardBorder,
      ),
    );
  }
}

class _SignalBarsPainter extends CustomPainter {
  final int litBars; // 1–4
  final Color activeColor;
  final Color dimColor;

  _SignalBarsPainter({
    required this.litBars,
    required this.activeColor,
    required this.dimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final strokeWidth = size.width * 0.09;

    // 4 arcs, each with increasing radius
    final radii = [
      size.width * 0.18,
      size.width * 0.32,
      size.width * 0.46,
      size.width * 0.60,
    ];

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < 4; i++) {
      paint.color = (i < litBars) ? activeColor : dimColor;
      final r = radii[i];
      const sweep = 1.3; // radians
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -1.5707 - sweep / 2, // start: top-center minus half sweep
        sweep,
        false,
        paint,
      );
    }

    // Center dot
    final dotPaint = Paint()
      ..color = litBars > 0 ? activeColor : dimColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx, cy - strokeWidth * 0.4),
      strokeWidth * 0.6,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(_SignalBarsPainter old) =>
      old.litBars != litBars ||
      old.activeColor != activeColor ||
      old.dimColor != dimColor;
}
