import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/features/threat_intel/widgets/threat_alert_card.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';
import 'package:optisec_mobile/shared/models/threat_alert_model.dart';

/// Regression test for the audit finding: threat_intel_view.dart and
/// threat_alert_card.dart imported/used AppLocalizations nowhere at all, so
/// every UI string (severity labels, "time ago", empty/loading states) was
/// hardcoded English regardless of the app's Arabic locale. This verifies
/// ThreatAlertCard now actually renders the Arabic strings when the locale
/// is Arabic (remote feed content -- title/region/description -- is left
/// as-is since it comes from a live external feed, not app UI chrome).
void main() {
  final alert = ThreatAlert(
    id: 'a1',
    severity: AlertSeverity.critical,
    region: 'Global',
    title: 'Sample Threat',
    description: 'Sample description',
    publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
  );

  Future<void> pump(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: ThreatAlertCard(alert: alert, index: 0)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders English severity/time strings under the English locale',
      (tester) async {
    await pump(tester, const Locale('en'));

    expect(find.text('CRITICAL'), findsOneWidget);
    expect(find.text('3h ago'), findsOneWidget);
  });

  testWidgets('renders Arabic severity/time strings under the Arabic locale',
      (tester) async {
    await pump(tester, const Locale('ar'));

    expect(find.text('حرج'), findsOneWidget);
    expect(find.text('قبل 3 س'), findsOneWidget);
    // The hardcoded English strings must be gone under Arabic.
    expect(find.text('CRITICAL'), findsNothing);
  });
}
