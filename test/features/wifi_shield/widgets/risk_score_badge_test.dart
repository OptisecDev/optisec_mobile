import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/theme/app_colors.dart';
import 'package:optisec_mobile/features/wifi_shield/widgets/risk_score_badge.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';
import 'package:optisec_mobile/shared/models/wifi_network_model.dart';

/// Regression test for the audit finding: RiskScoreBadge used to derive its
/// own color from raw score thresholds independent of ThreatBadge (which is
/// driven by the controller's ThreatLevel), so a network scoring 25-39
/// showed safe/green here and warning/orange there. RiskScoreBadge is now
/// driven by the same ThreatLevel, so this can no longer happen.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(body: child),
        ),
      );

  Color scoreTextColor(WidgetTester tester, int score) {
    final texts = tester.widgetList<Text>(find.text('$score'));
    return (texts.single.style!.color)!;
  }

  testWidgets(
      'a score of 30 with ThreatLevel.safe renders safe (green), not warning',
      (tester) async {
    // This is exactly the previously-contradictory case: the old
    // score>=20 threshold alone would have classified 30 as "Medium"
    // (warning color), even though the controller's actual classification
    // for this network is safe.
    await pump(
      tester,
      const RiskScoreBadge(score: 30, level: ThreatLevel.safe),
    );

    expect(scoreTextColor(tester, 30), AppColors.safe);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsNothing);
  });

  testWidgets('ThreatLevel.warning always renders warning color and Medium',
      (tester) async {
    await pump(
      tester,
      const RiskScoreBadge(score: 42, level: ThreatLevel.warning),
    );

    expect(scoreTextColor(tester, 42), AppColors.warning);
    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('ThreatLevel.danger with score >= 70 renders Critical',
      (tester) async {
    await pump(
      tester,
      const RiskScoreBadge(score: 85, level: ThreatLevel.danger),
    );

    expect(scoreTextColor(tester, 85), AppColors.danger);
    expect(find.text('Critical'), findsOneWidget);
  });

  testWidgets('ThreatLevel.danger with score < 70 renders High, still danger color',
      (tester) async {
    await pump(
      tester,
      const RiskScoreBadge(score: 55, level: ThreatLevel.danger),
    );

    expect(scoreTextColor(tester, 55), AppColors.danger);
    expect(find.text('High'), findsOneWidget);
  });
}
