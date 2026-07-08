import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/services/vault_clipboard_guard.dart';

/// VaultClipboardGuard.instance is a private-constructor singleton with no
/// reset hook, so its mutable state (`_holdsVaultContent`/`_clearTimer`)
/// persists across tests in this isolate. tearDown drives it back to a known
/// state through the only public API available: clearIfHoldingVaultContent,
/// which safely no-ops if nothing is held and otherwise cancels any pending
/// timer and clears the flag -- exactly what we want between tests.
///
/// The auto-clear delay is a plain Timer (not a DateTime.now() read), so
/// tester.pump(duration) reliably fires it without needing tester.runAsync.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final clipboardCalls = <MethodCall>[];

  setUp(() {
    clipboardCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardCalls.add(call);
      }
      return null;
    });
  });

  tearDown(() async {
    await VaultClipboardGuard.instance.clearIfHoldingVaultContent();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('copy writes the text to the clipboard and marks it as held',
      (tester) async {
    await VaultClipboardGuard.instance.copy('super-secret-pw');

    expect(clipboardCalls, hasLength(1));
    expect(clipboardCalls.single.arguments, {'text': 'super-secret-pw'});
    expect(VaultClipboardGuard.instance.holdsVaultContent, isTrue);

    // copy() leaves a 35s auto-clear Timer pending; the test binding's
    // invariant check runs before tearDown, so it must be cancelled here.
    await VaultClipboardGuard.instance.clearIfHoldingVaultContent();
  });

  testWidgets(
    'auto-clears the clipboard 35 seconds after copy, not before',
    (tester) async {
      await VaultClipboardGuard.instance.copy('super-secret-pw');
      clipboardCalls.clear();

      await tester.pump(const Duration(seconds: 34));
      expect(VaultClipboardGuard.instance.holdsVaultContent, isTrue);
      expect(clipboardCalls, isEmpty);

      await tester.pump(const Duration(seconds: 1));
      expect(VaultClipboardGuard.instance.holdsVaultContent, isFalse);
      expect(clipboardCalls, hasLength(1));
      expect(clipboardCalls.single.arguments, {'text': ''});
    },
  );

  testWidgets(
    'clearIfHoldingVaultContent (lock) clears immediately and cancels the pending auto-clear',
    (tester) async {
      await VaultClipboardGuard.instance.copy('super-secret-pw');
      clipboardCalls.clear();

      await VaultClipboardGuard.instance.clearIfHoldingVaultContent();

      expect(VaultClipboardGuard.instance.holdsVaultContent, isFalse);
      expect(clipboardCalls, hasLength(1));
      expect(clipboardCalls.single.arguments, {'text': ''});

      // The auto-clear timer must have been cancelled -- letting fake time
      // run well past the original 35s delay should not clear again.
      clipboardCalls.clear();
      await tester.pump(const Duration(seconds: 40));
      expect(clipboardCalls, isEmpty);
    },
  );

  testWidgets(
    'clearIfHoldingVaultContent is a no-op when nothing vault-related was copied',
    (tester) async {
      expect(VaultClipboardGuard.instance.holdsVaultContent, isFalse);

      await VaultClipboardGuard.instance.clearIfHoldingVaultContent();

      expect(clipboardCalls, isEmpty);
    },
  );

  testWidgets(
    'a second copy resets the 35 second auto-clear window',
    (tester) async {
      await VaultClipboardGuard.instance.copy('first-secret');
      clipboardCalls.clear();

      await tester.pump(const Duration(seconds: 20));
      await VaultClipboardGuard.instance.copy('second-secret');
      clipboardCalls.clear();

      // 20s (already elapsed) + 20s more = 40s total, which is past the
      // *original* copy's 35s mark -- if the timer weren't reset, this
      // would already have cleared.
      await tester.pump(const Duration(seconds: 20));
      expect(VaultClipboardGuard.instance.holdsVaultContent, isTrue);
      expect(clipboardCalls, isEmpty);

      // 15s more completes the *second* copy's own 35s window.
      await tester.pump(const Duration(seconds: 15));
      expect(VaultClipboardGuard.instance.holdsVaultContent, isFalse);
      expect(clipboardCalls, hasLength(1));
      expect(clipboardCalls.single.arguments, {'text': ''});
    },
  );
}
