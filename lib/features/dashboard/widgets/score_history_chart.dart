import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreHistoryChart extends StatefulWidget {
  final List<double> scores;

  const ScoreHistoryChart({super.key, required this.scores});

  @override
  State<ScoreHistoryChart> createState() => _ScoreHistoryChartState();
}

class _ScoreHistoryChartState extends State<ScoreHistoryChart> {
  int? _touched;

  // Day labels offset from today backwards
  List<String> get _dayLabels {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[d.weekday - 1];
    });
  }

  Color _dotColor(double val) {
    if (val >= 80) return AppColors.safe;
    if (val >= 60) return AppColors.primary;
    if (val >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final labels = _dayLabels;
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            setState(() {
              if (response?.lineBarSpots != null &&
                  response!.lineBarSpots!.isNotEmpty) {
                _touched = response.lineBarSpots!.first.spotIndex;
              } else {
                _touched = null;
              }
            });
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceVariant,
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '${s.y.toInt()}',
                TextStyle(
                  color: _dotColor(s.y),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(
                    text: '/100',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (val) => FlLine(
            color: val == 0 || val == 100
                ? Colors.transparent
                : AppColors.cardBorder.withOpacity(0.6),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 28,
              getTitlesWidget: (val, _) => Text(
                val.toInt() == 0 ? '' : '${val.toInt()}',
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, _) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                final isToday = i == labels.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    isToday ? 'Today' : labels[i],
                    style: TextStyle(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textDisabled,
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: widget.scores.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, index) {
                final isTouched = index == _touched;
                final c = _dotColor(spot.y);
                return FlDotCirclePainter(
                  radius: isTouched ? 6 : 4,
                  color: isTouched ? c : AppColors.background,
                  strokeWidth: isTouched ? 0 : 2.5,
                  strokeColor: c,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
