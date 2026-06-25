import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ThreatTimelineChart extends StatefulWidget {
  final List<double> threatCounts; // 7 values, oldest first

  const ThreatTimelineChart({super.key, required this.threatCounts});

  @override
  State<ThreatTimelineChart> createState() => _ThreatTimelineChartState();
}

class _ThreatTimelineChartState extends State<ThreatTimelineChart> {
  int? _touched;

  List<String> get _dayLabels {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const short = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return short[d.weekday - 1];
    });
  }

  Color _barColor(double val, bool touched) {
    if (val == 0) return AppColors.safe.withOpacity(touched ? 1.0 : 0.7);
    if (val <= 2) return AppColors.warning.withOpacity(touched ? 1.0 : 0.8);
    return AppColors.danger.withOpacity(touched ? 1.0 : 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final labels = _dayLabels;
    final maxY =
        (widget.threatCounts.reduce((a, b) => a > b ? a : b) + 2)
            .clamp(6, 20)
            .toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchCallback: (event, response) {
            setState(() {
              if (response?.spot != null) {
                _touched = response!.spot!.touchedBarGroupIndex;
              } else {
                _touched = null;
              }
            });
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceVariant,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final val = rod.toY.toInt();
              return BarTooltipItem(
                '$val ${val == 1 ? 'threat' : 'threats'}',
                TextStyle(
                  color: _barColor(rod.toY, true),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
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
                    isToday ? '●' : labels[i],
                    style: TextStyle(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textDisabled,
                      fontSize: isToday ? 12 : 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: maxY <= 6 ? 2 : 3,
              getTitlesWidget: (val, _) => Text(
                val.toInt() == 0 ? '' : '${val.toInt()}',
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.cardBorder.withOpacity(0.5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: widget.threatCounts.asMap().entries.map((e) {
          final isTouched = e.key == _touched;
          final color = _barColor(e.value, isTouched);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: color,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.cardBorder.withOpacity(0.15),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
