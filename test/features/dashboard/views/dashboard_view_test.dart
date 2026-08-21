import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optisec_mobile/features/dashboard/controllers/dashboard_controller.dart';
import 'package:optisec_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:optisec_mobile/features/threat_intel/controllers/threat_intel_controller.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';
import 'package:optisec_mobile/shared/models/security_score_model.dart';

/// Regression test for the notification bell: DashboardView's AppBar bell
/// scrolls to the "Active Threats" section via a module-level GlobalKey
/// looked up in onPressed. When that section lived in a lazily-built
/// SliverList, the GlobalKey's context was null (so the tap silently did
/// nothing) until the user had already scrolled it near-visible. Fixed by
/// building the dashboard's sections eagerly (SliverToBoxAdapter + Column
/// instead of SliverList) so the section's context always exists.
///
/// Stub controllers skip the real onInit() -- DashboardController's needs
/// WifiShieldController/PrivacyGuardController/AppLockService, and
/// ThreatIntelController's fires a real network/storage fetch -- neither of
/// which this test needs, since the score shown is set directly.
class _StubDashboardController extends DashboardController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _StubThreatIntelController extends ThreatIntelController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDir = Directory.systemTemp.createTempSync('dashboard_view_test');
  const pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (call) async {
    if (call.method == 'getApplicationDocumentsDirectory') return tempDir.path;
    return null;
  });

  setUpAll(() async {
    await GetStorage.init();
  });

  tearDown(() => Get.reset());

  testWidgets(
      'tapping the notification bell scrolls the Active Threats section into view',
      (tester) async {
    final controller = _StubDashboardController();
    controller.score.value = SecurityScoreModel(
      overall: 70,
      wifiScore: 70,
      privacyScore: 70,
      appScore: 70,
      threatsDetected: 1,
      networksScanned: 1,
      lastScan: DateTime(2026, 8, 21),
      threats: [
        ThreatItem(
          id: 't1',
          title: 'Open WiFi detected',
          description: 'Unsecured network nearby',
          severity: ThreatSeverity.high,
          category: 'wifi',
          detectedAt: DateTime(2026, 8, 21),
        ),
      ],
    );
    Get.put<DashboardController>(controller);
    Get.put<ThreatIntelController>(_StubThreatIntelController());

    await tester.pumpWidget(
      GetMaterialApp(
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const DashboardView(),
      ),
    );
    await tester.pumpAndSettle();

    // Sanity check: the section is built (proves the fix -- it isn't
    // skipped by lazy sliver building) but starts below the fold. The
    // threat's own title is used instead of the "Active Threats" heading
    // because that heading text is reused (differently styled) by the
    // stats grid above.
    final viewport = tester.getRect(find.byType(Scaffold));
    final threatTitle = find.text('Open WiFi detected');
    expect(threatTitle, findsOneWidget);
    expect(tester.getTopLeft(threatTitle).dy, greaterThan(viewport.bottom));

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(
      viewport.contains(tester.getTopLeft(threatTitle)),
      isTrue,
      reason: 'tapping the bell should scroll "Active Threats" into view',
    );
  });
}
