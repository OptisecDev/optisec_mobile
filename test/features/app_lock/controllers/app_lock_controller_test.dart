import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/app_lock/controllers/app_lock_controller.dart';
import 'package:optisec_mobile/navigation/app_routes.dart';

/// AppLockController talks to AppLockService.instance, which is a
/// private-constructor singleton with no injection point. Same technique as
/// app_lock_service_test.dart: mock at the MethodChannel level.
///
/// toggleLock() gates the *second and later* locked app behind
/// SubscriptionController.checkAccessOrPrompt (see FeatureGate.freeAppLockLimit
/// in subscription_model.dart), which in turn depends on PurchaseService /
/// LicenseKeyService (real in_app_purchase plumbing). No test in this
/// codebase currently stands up that dependency chain, and building it is
/// out of scope for App Lock coverage, so these tests exercise toggleLock()
/// only via paths that don't reach the paywall check: adding the very
/// first locked app (explicitly unpaywalled) and removing an already-locked
/// app (also unpaywalled). The paywalled branch itself is untested here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const appLockChannel = MethodChannel('com.optisec.mobile/app_lock');

  final appLockCalls = <MethodCall>[];
  Map<String, Object?> channelResponses = {};

  Map<String, Object?> defaultResponses() => {
        'getInstalledApps': <Map<String, dynamic>>[
          {'packageName': 'com.example.one', 'appName': 'Alpha', 'icon': null},
          {'packageName': 'com.example.two', 'appName': 'Beta', 'icon': null},
        ],
        'getLockedApps': <String>[],
        'isPinSet': true,
        'hasOverlayPermission': true,
        'isIgnoringBatteryOptimizations': true,
      };

  setUp(() {
    appLockCalls.clear();
    channelResponses = defaultResponses();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLockChannel, (call) async {
      appLockCalls.add(call);
      return channelResponses[call.method];
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLockChannel, null);
    Get.reset();
  });

  Future<AppLockController> pumpController(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SizedBox()),
          GetPage(name: AppRoutes.pinSetup, page: () => const SizedBox()),
        ],
      ),
    );
    final controller = Get.put(AppLockController());
    await tester.pumpAndSettle();
    return controller;
  }

  group('initial load', () {
    testWidgets('populates installedApps, lockedPackages, and flags from the channel',
        (tester) async {
      channelResponses['getLockedApps'] = <String>['com.example.one'];
      channelResponses['hasOverlayPermission'] = false;
      channelResponses['isIgnoringBatteryOptimizations'] = false;

      final controller = await pumpController(tester);

      expect(controller.isLoading.value, isFalse);
      expect(controller.installedApps, hasLength(2));
      expect(controller.lockedPackages, {'com.example.one'});
      expect(controller.isPinSet.value, isTrue);
      expect(controller.hasOverlayPermission.value, isFalse);
      expect(controller.isIgnoringBatteryOptimizations.value, isFalse);
    });

    testWidgets('isLoading is true synchronously after put, false once settled',
        (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [GetPage(name: '/', page: () => const SizedBox())],
        ),
      );
      final controller = Get.put(AppLockController());

      expect(controller.isLoading.value, isTrue);

      await tester.pumpAndSettle();

      expect(controller.isLoading.value, isFalse);
    });
  });

  group('isLocked / filteredApps', () {
    testWidgets('isLocked reflects lockedPackages membership', (tester) async {
      channelResponses['getLockedApps'] = <String>['com.example.one'];
      final controller = await pumpController(tester);

      expect(controller.isLocked('com.example.one'), isTrue);
      expect(controller.isLocked('com.example.two'), isFalse);
    });

    testWidgets('filteredApps returns everything when the query is empty',
        (tester) async {
      final controller = await pumpController(tester);

      expect(controller.filteredApps, hasLength(2));
    });

    testWidgets('filteredApps filters case-insensitively by app name',
        (tester) async {
      final controller = await pumpController(tester);

      controller.searchQuery.value = 'alp';

      expect(controller.filteredApps, hasLength(1));
      expect(controller.filteredApps.single.packageName, 'com.example.one');
    });

    testWidgets('filteredApps trims whitespace in the query', (tester) async {
      final controller = await pumpController(tester);

      controller.searchQuery.value = '  beta  ';

      expect(controller.filteredApps.single.appName, 'Beta');
    });
  });

  group('toggleLock when no PIN is set', () {
    testWidgets('routes to pin setup and does not touch lockedPackages',
        (tester) async {
      channelResponses['isPinSet'] = false;
      final controller = await pumpController(tester);
      expect(controller.isPinSet.value, isFalse);
      appLockCalls.clear();

      await controller.toggleLock('com.example.one');
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.pinSetup);
      expect(controller.lockedPackages, isEmpty);
      expect(
        appLockCalls.where((c) => c.method == 'setLockedApps'),
        isEmpty,
      );
    });
  });

  group('toggleLock adding the first locked app (unpaywalled)', () {
    testWidgets('adds the package, persists it, and starts the monitor service',
        (tester) async {
      final controller = await pumpController(tester);
      expect(controller.lockedPackages, isEmpty);
      appLockCalls.clear();

      await controller.toggleLock('com.example.one');
      await tester.pumpAndSettle();

      expect(controller.lockedPackages, {'com.example.one'});

      final setLockedCall =
          appLockCalls.firstWhere((c) => c.method == 'setLockedApps');
      expect(
        (setLockedCall.arguments as List).cast<String>().toSet(),
        {'com.example.one'},
      );
      expect(
        appLockCalls.map((c) => c.method),
        contains('startMonitorService'),
      );
    });
  });

  group('toggleLock removing a locked app (unpaywalled)', () {
    testWidgets('removes the package, persists it, and stops the monitor service',
        (tester) async {
      channelResponses['getLockedApps'] = <String>['com.example.one'];
      final controller = await pumpController(tester);
      expect(controller.lockedPackages, {'com.example.one'});
      appLockCalls.clear();

      await controller.toggleLock('com.example.one');
      await tester.pumpAndSettle();

      expect(controller.lockedPackages, isEmpty);

      final setLockedCall =
          appLockCalls.firstWhere((c) => c.method == 'setLockedApps');
      expect(setLockedCall.arguments, isEmpty);
      expect(
        appLockCalls.map((c) => c.method),
        contains('stopMonitorService'),
      );
    });

    testWidgets('removing one of several locked apps keeps the monitor running',
        (tester) async {
      channelResponses['getLockedApps'] =
          <String>['com.example.one', 'com.example.two'];
      final controller = await pumpController(tester);
      appLockCalls.clear();

      await controller.toggleLock('com.example.one');
      await tester.pumpAndSettle();

      expect(controller.lockedPackages, {'com.example.two'});
      expect(
        appLockCalls.map((c) => c.method),
        contains('startMonitorService'),
      );
      expect(
        appLockCalls.map((c) => c.method),
        isNot(contains('stopMonitorService')),
      );
    });
  });

  group('showBatteryOptimizationBanner', () {
    testWidgets('is false when there are no locked packages', (tester) async {
      channelResponses['isIgnoringBatteryOptimizations'] = false;
      final controller = await pumpController(tester);

      expect(controller.lockedPackages, isEmpty);
      expect(controller.showBatteryOptimizationBanner, isFalse);
    });

    testWidgets('is false when battery optimization is already ignored',
        (tester) async {
      channelResponses['getLockedApps'] = <String>['com.example.one'];
      channelResponses['isIgnoringBatteryOptimizations'] = true;
      final controller = await pumpController(tester);

      expect(controller.showBatteryOptimizationBanner, isFalse);
    });

    testWidgets(
      'is true when there is a locked package and battery optimization is not ignored',
      (tester) async {
        channelResponses['getLockedApps'] = <String>['com.example.one'];
        channelResponses['isIgnoringBatteryOptimizations'] = false;
        final controller = await pumpController(tester);

        expect(controller.showBatteryOptimizationBanner, isTrue);
      },
    );
  });

  group('refreshPermissionStatus', () {
    testWidgets('re-reads overlay permission, battery optimization, and PIN status',
        (tester) async {
      final controller = await pumpController(tester);
      expect(controller.hasOverlayPermission.value, isTrue);

      channelResponses['hasOverlayPermission'] = false;
      channelResponses['isIgnoringBatteryOptimizations'] = false;
      channelResponses['isPinSet'] = false;

      await controller.refreshPermissionStatus();

      expect(controller.hasOverlayPermission.value, isFalse);
      expect(controller.isIgnoringBatteryOptimizations.value, isFalse);
      expect(controller.isPinSet.value, isFalse);
    });
  });

  group('openOverlaySettings / requestIgnoreBatteryOptimizations', () {
    testWidgets('openOverlaySettings forwards to the channel', (tester) async {
      final controller = await pumpController(tester);
      appLockCalls.clear();

      await controller.openOverlaySettings();

      expect(appLockCalls.single.method, 'openOverlaySettings');
    });

    testWidgets('requestIgnoreBatteryOptimizations forwards to the channel',
        (tester) async {
      final controller = await pumpController(tester);
      appLockCalls.clear();

      await controller.requestIgnoreBatteryOptimizations();

      expect(appLockCalls.single.method, 'requestIgnoreBatteryOptimizations');
    });
  });
}
