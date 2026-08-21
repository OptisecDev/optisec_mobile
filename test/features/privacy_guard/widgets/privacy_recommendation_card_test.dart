import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/theme/app_colors.dart';
import 'package:optisec_mobile/features/privacy_guard/controllers/privacy_guard_controller.dart';
import 'package:optisec_mobile/features/privacy_guard/widgets/privacy_recommendation_card.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';

/// Regression test for the audit finding: the "Fix" button used to call
/// controller.runScan() (just a re-scan) regardless of which recommendation
/// it was on, and the recommendation list itself was a fixed 3-item
/// constant unrelated to actual permission state. PrivacyRecommendationCard
/// is now driven directly by a real, granted PermissionInfo, and the caller
/// (privacy_guard_view.dart) wires its action to controller.revokePermission
/// (opens system settings) -- this test verifies the card renders that real
/// permission's data and that tapping it fires whatever action it's given,
/// which is the seam that view wiring depends on.
void main() {
  const micPermission = PermissionInfo(
    id: 'microphone',
    nameEn: 'Microphone',
    nameAr: 'الميكروفون',
    icon: Icons.mic_rounded,
    isGranted: true,
    appsCount: 4,
    risk: 'high',
    descriptionEn:
        'One of the highest-risk permissions. Apps with mic access can record conversations without obvious indication.',
    descriptionAr: 'وصف عربي',
    recommendationEn: 'Revoke microphone from all apps except voice calls.',
    recommendationAr: 'توصية عربية',
  );

  Future<void> pump(WidgetTester tester, VoidCallback onAction) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: PrivacyRecommendationCard(
            permission: micPermission,
            index: 0,
            onAction: onAction,
          ),
        ),
      ),
    );
  }

  testWidgets('renders the real permission name, description, and risk color',
      (tester) async {
    await pump(tester, () {});
    // Let the card's flutter_animate fade/slide-in finish, or its pending
    // Timer trips flutter_test's post-test invariant check.
    await tester.pumpAndSettle();

    expect(find.text('Microphone Access Granted'), findsOneWidget);
    expect(find.text(micPermission.descriptionEn), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.mic_rounded));
    expect(icon.color, AppColors.danger); // risk == 'high'
  });

  testWidgets('tapping the action button invokes the provided callback',
      (tester) async {
    var tapped = false;
    await pump(tester, () => tapped = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fix'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
