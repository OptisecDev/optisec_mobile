import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optisec_mobile/features/dashboard/controllers/dashboard_controller.dart';
import 'package:optisec_mobile/features/settings/controllers/settings_controller.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// GetStorage needs a real documents-directory path even under `flutter
/// test`, so path_provider's channel is mocked to a throwaway temp dir --
/// same technique as elsewhere in this suite for platform channels.
///
/// SettingsController.clearScanHistory()/resetAllData() reach for
/// AppLocalizations.of(Get.context!) to show a snackbar, so those tests
/// pump a real GetMaterialApp with the localization delegates wired up,
/// mirroring main.dart's setup.
///
/// _StubDashboardController skips the real onInit() (which needs
/// WifiShieldController and PrivacyGuardController registered) since these
/// tests only care whether SettingsController calls clearHistory() at all.
class _StubDashboardController extends DashboardController {
  int clearHistoryCalls = 0;

  @override
  void onInit() {}

  @override
  void clearHistory() {
    clearHistoryCalls++;
    super.clearHistory();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDir =
      Directory.systemTemp.createTempSync('settings_controller_test');
  const pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (call) async {
    if (call.method == 'getApplicationDocumentsDirectory') return tempDir.path;
    return null;
  });

  setUpAll(() async {
    await GetStorage.init();
    // SettingsController.onInit() calls PackageInfo.fromPlatform(), which
    // has no real platform channel implementation under `flutter test`.
    PackageInfo.setMockInitialValues(
      appName: 'OptiSec',
      packageName: 'com.optisec.optisec_mobile',
      version: '1.1.0',
      buildNumber: '2',
      buildSignature: '',
    );
  });

  setUp(() async {
    await GetStorage().erase();
  });

  tearDown(() {
    Get.closeAllSnackbars();
    Get.reset();
  });

  /// Get.snackbar()'s 3-second auto-dismiss timer is a real dart:async
  /// Timer. If it's still pending when a test ends, it fires into a torn-
  /// down widget tree and fails a *later* test with a confusing
  /// "after it had already completed" error. Running the real work plus a
  /// real 4-second wait inside one runAsync block lets that timer actually
  /// fire before this test (and Get.reset() in tearDown) finishes.
  Future<void> runAndSettle(
    WidgetTester tester,
    Future<void> Function() action,
  ) async {
    await tester.runAsync(() async {
      await action();
      await Future<void>.delayed(const Duration(seconds: 4));
    });
    await tester.pump();
  }

  Future<SettingsController> pumpController(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        getPages: [GetPage(name: '/', page: () => const SizedBox())],
      ),
    );
    final controller = Get.put(SettingsController());
    await tester.pumpAndSettle();
    return controller;
  }

  group('persistence', () {
    test('onInit loads defaults when nothing is persisted yet', () {
      final c = SettingsController();
      c.onInit();
      expect(c.language.value, 'en');
      expect(c.autoScan.value, true);
      expect(c.scanIntervalMinutes.value, 15);
    });

    test('changing a value persists it, and a fresh controller loads it back',
        () {
      final c1 = SettingsController();
      c1.onInit();
      c1.autoScan.value = false;
      c1.scanIntervalMinutes.value = 60;
      c1.evilTwinAlerts.value = false;
      c1.biometricLock.value = true;
      c1.language.value = 'ar';

      final c2 = SettingsController();
      c2.onInit();
      expect(c2.autoScan.value, false);
      expect(c2.scanIntervalMinutes.value, 60);
      expect(c2.evilTwinAlerts.value, false);
      expect(c2.biometricLock.value, true);
      expect(c2.language.value, 'ar');
    });
  });

  group('resetAllData', () {
    testWidgets('restores every persisted field to its default, in storage too',
        (tester) async {
      final c1 = await pumpController(tester);
      c1.autoScan.value = false;
      c1.scanIntervalMinutes.value = 60;
      c1.evilTwinAlerts.value = false;
      c1.vpnDetection.value = false;
      c1.pushNotifications.value = false;
      c1.threatAlerts.value = false;
      c1.weeklyReport.value = true;
      c1.biometricLock.value = true;
      c1.analyticsEnabled.value = false;
      c1.setLanguage('ar');

      await runAndSettle(tester, c1.resetAllData);

      expect(c1.language.value, 'en');
      expect(c1.autoScan.value, true);
      expect(c1.scanIntervalMinutes.value, 15);
      expect(c1.evilTwinAlerts.value, true);
      expect(c1.vpnDetection.value, true);
      expect(c1.pushNotifications.value, true);
      expect(c1.threatAlerts.value, true);
      expect(c1.weeklyReport.value, false);
      expect(c1.biometricLock.value, false);
      expect(c1.analyticsEnabled.value, true);

      // Round-tripped through storage, not just the in-memory Rx fields.
      final c2 = SettingsController();
      c2.onInit();
      expect(c2.autoScan.value, true);
      expect(c2.language.value, 'en');
    });

    testWidgets('clears the dashboard-owned scan/threat history when registered',
        (tester) async {
      final dashboard = _StubDashboardController();
      Get.put<DashboardController>(dashboard);

      final c = await pumpController(tester);
      await runAndSettle(tester, c.resetAllData);

      expect(dashboard.clearHistoryCalls, 1);
    });

    testWidgets('does not throw when DashboardController is not registered',
        (tester) async {
      final c = await pumpController(tester);
      await runAndSettle(tester, c.resetAllData);
    });
  });

  group('clearScanHistory', () {
    testWidgets('clears the dashboard-owned scan/threat history when registered',
        (tester) async {
      final dashboard = _StubDashboardController();
      Get.put<DashboardController>(dashboard);

      final c = await pumpController(tester);
      await runAndSettle(tester, c.clearScanHistory);

      expect(dashboard.clearHistoryCalls, 1);
    });

    testWidgets('does not touch any settings', (tester) async {
      final c = await pumpController(tester);
      c.autoScan.value = false;

      await runAndSettle(tester, c.clearScanHistory);

      expect(c.autoScan.value, false);
    });
  });
}
