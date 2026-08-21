import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/theme/app_colors.dart';
import 'package:optisec_mobile/shared/models/security_score_model.dart';

/// Regression test for the audit finding: the >=80/>=60/>=40 score
/// thresholds used to be hand-copied independently in score_ring.dart,
/// score_history_chart.dart, security_report_pdf_service.dart, and
/// privacy_guard_view.dart. This verifies the single shared source those
/// files now all defer to.
void main() {
  group('scoreTierFor', () {
    test('boundary values land in the correct tier', () {
      expect(scoreTierFor(100), ScoreTier.safe);
      expect(scoreTierFor(80), ScoreTier.safe);
      expect(scoreTierFor(79), ScoreTier.good);
      expect(scoreTierFor(60), ScoreTier.good);
      expect(scoreTierFor(59), ScoreTier.warning);
      expect(scoreTierFor(40), ScoreTier.warning);
      expect(scoreTierFor(39), ScoreTier.critical);
      expect(scoreTierFor(0), ScoreTier.critical);
    });
  });

  group('scoreColorFor', () {
    test('maps each tier to the correct AppColors constant', () {
      expect(scoreColorFor(80), AppColors.safe);
      expect(scoreColorFor(60), AppColors.primary);
      expect(scoreColorFor(40), AppColors.warning);
      expect(scoreColorFor(0), AppColors.danger);
    });
  });

  group('scoreStatusLabelFor', () {
    test('maps each tier to the correct English label', () {
      expect(scoreStatusLabelFor(80), 'Excellent');
      expect(scoreStatusLabelFor(60), 'Good');
      expect(scoreStatusLabelFor(40), 'Fair');
      expect(scoreStatusLabelFor(0), 'Critical');
    });
  });

  group('SecurityScoreModel.statusLabel', () {
    test('stays consistent with scoreStatusLabelFor for the same score', () {
      for (final score in [0, 39, 40, 59, 60, 79, 80, 100]) {
        final model = SecurityScoreModel(
          overall: score,
          wifiScore: 0,
          privacyScore: 0,
          appScore: 0,
          threatsDetected: 0,
          networksScanned: 0,
          lastScan: DateTime.now(),
        );
        expect(model.statusLabel, scoreStatusLabelFor(score));
      }
    });
  });
}
