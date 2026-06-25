import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreBreakdownChart extends StatelessWidget {
  final int wifiScore;
  final int privacyScore;
  final int appScore;

  const ScoreBreakdownChart({
    super.key,
    required this.wifiScore,
    required this.privacyScore,
    required this.appScore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                // Faint max reference
                RadarDataSet(
                  dataEntries: const [
                    RadarEntry(value: 100),
                    RadarEntry(value: 100),
                    RadarEntry(value: 100),
                  ],
                  borderColor: Colors.transparent,
                  fillColor: AppColors.cardBorder.withOpacity(0.15),
                  borderWidth: 0,
                  entryRadius: 0,
                ),
                // Actual scores
                RadarDataSet(
                  dataEntries: [
                    RadarEntry(value: wifiScore.toDouble()),
                    RadarEntry(value: privacyScore.toDouble()),
                    RadarEntry(value: appScore.toDouble()),
                  ],
                  borderColor: AppColors.primary,
                  fillColor: AppColors.primary.withOpacity(0.15),
                  borderWidth: 2,
                  entryRadius: 4,
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              radarBorderData: const BorderSide(
                  color: AppColors.cardBorder, width: 1),
              gridBorderData: const BorderSide(
                  color: AppColors.cardBorder, width: 1),
              tickBorderData: BorderSide(
                  color: AppColors.cardBorder.withOpacity(0.4), width: 1),
              tickCount: 4,
              ticksTextStyle: const TextStyle(
                  color: Colors.transparent, fontSize: 0),
              titleTextStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              titlePositionPercentageOffset: 0.18,
              getTitle: (index, angle) {
                const labels = ['WiFi', 'Privacy', 'Apps'];
                return RadarChartTitle(
                  text: labels[index],
                  angle: angle,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Legend column
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendRow('WiFi', wifiScore, AppColors.info),
              const SizedBox(height: 16),
              _legendRow('Privacy', privacyScore, AppColors.primary),
              const SizedBox(height: 16),
              _legendRow('Apps', appScore, AppColors.accent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '$score',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 4,
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
