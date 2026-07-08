import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/password_vault/controllers/vault_controller.dart';
import 'package:optisec_mobile/navigation/app_routes.dart';
import 'package:optisec_mobile/shared/models/vault_entry_model.dart';

/// VaultController talks to PasswordVaultService.instance, which is a
/// private-constructor singleton with no injection point. Since this is a
/// test-only change (no source edits allowed), we mock at the MethodChannel
/// level instead -- same technique as password_vault_service_test.dart --
/// which fully isolates these tests from real native code while still
/// letting us assert exactly which native calls the controller triggers.
///
/// The auto-lock check compares real DateTime.now() timestamps, so tests
/// that need actual wall-clock time to pass between "paused" and "resumed"
/// use `tester.runAsync` to escape flutter_test's fake-time zone -- a bare
/// `await Future.delayed(...)` never fires because the test binding's fake
/// clock only advances on `tester.pump(duration)`, not on its own.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const vaultChannel = MethodChannel('com.optisec.mobile/password_vault');
  const screenSecurityChannel =
      MethodChannel('com.optisec.mobile/screen_security');

  final vaultCalls = <MethodCall>[];

  VaultEntryModel fakeEntry(String id) => VaultEntryModel(
        id: id,
        title: 'Title $id',
        username: 'user',
        url: 'https://example.com',
        notes: '',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

  setUp(() {
    vaultCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vaultChannel, (call) async {
      vaultCalls.add(call);
      switch (call.method) {
        case 'listEntries':
          return <Map<String, dynamic>>[];
        case 'getAutoLockTimeoutMillis':
          return 60000;
        default:
          return null;
      }
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      screenSecurityChannel,
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vaultChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(screenSecurityChannel, null);
    Get.reset();
  });

  Future<VaultController> pumpController(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SizedBox()),
          GetPage(name: AppRoutes.vaultUnlock, page: () => const SizedBox()),
        ],
      ),
    );
    final controller = Get.put(VaultController());
    await tester.pumpAndSettle();
    return controller;
  }

  group('auto-lock on app lifecycle changes', () {
    testWidgets(
      'resuming after the timeout has elapsed triggers lock()',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);
        controller.autoLockTimeout.value = const Duration(milliseconds: 30);

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, isEmpty);
        expect(vaultCalls.map((c) => c.method), contains('lockVault'));
        expect(Get.currentRoute, AppRoutes.vaultUnlock);
      },
    );

    testWidgets(
      'resuming before the timeout elapses does NOT trigger lock()',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);
        controller.autoLockTimeout.value = const Duration(seconds: 5);

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, hasLength(1));
        expect(vaultCalls.map((c) => c.method), isNot(contains('lockVault')));
        expect(Get.currentRoute, isNot(AppRoutes.vaultUnlock));
      },
    );

    testWidgets(
      'resuming without a prior pause does not trigger lock()',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);

        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, hasLength(1));
        expect(vaultCalls.map((c) => c.method), isNot(contains('lockVault')));
      },
    );
  });

  group('grace period suppression', () {
    testWidgets(
      'a pause/resume bracketed by begin/endGracePeriod is suppressed even past the timeout',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);
        controller.autoLockTimeout.value = const Duration(milliseconds: 30);

        controller.beginGracePeriod();
        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        // Resume happens *while still inside* the grace period bracket --
        // mirrors a system picker (export/import) returning control to the
        // app before the awaited native call itself has completed.
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, hasLength(1));
        expect(vaultCalls.map((c) => c.method), isNot(contains('lockVault')));

        controller.endGracePeriod();
      },
    );

    testWidgets(
      'grace suppression is not permanent -- a later pause/resume past the timeout locks normally',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);
        controller.autoLockTimeout.value = const Duration(milliseconds: 30);

        controller.beginGracePeriod();
        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        controller.endGracePeriod();
        await tester.pumpAndSettle();

        // Sanity: nothing locked yet from the bracketed cycle above.
        expect(controller.entries, hasLength(1));

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, isEmpty);
        expect(vaultCalls.map((c) => c.method), contains('lockVault'));
      },
    );
  });

  group('Duration.zero immediate-lock branch', () {
    testWidgets(
      'locks immediately on resume when autoLockTimeout is Duration.zero, even with no elapsed time',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);
        controller.autoLockTimeout.value = Duration.zero;

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        // No delay at all -- the zero-timeout branch must fire regardless.
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, isEmpty);
        expect(vaultCalls.map((c) => c.method), contains('lockVault'));
        expect(Get.currentRoute, AppRoutes.vaultUnlock);
      },
    );

    testWidgets(
      'a non-zero timeout does not use the immediate-lock branch when resumed instantly',
      (tester) async {
        final controller = await pumpController(tester);
        controller.entries.assignAll([fakeEntry('e1')]);
        controller.autoLockTimeout.value = const Duration(minutes: 1);

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.pumpAndSettle();

        expect(controller.entries, hasLength(1));
        expect(vaultCalls.map((c) => c.method), isNot(contains('lockVault')));
      },
    );
  });
}
