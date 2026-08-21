import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/services/screen_security_service.dart';

/// ScreenSecurityService.instance is a singleton, so this whole lifecycle
/// (several controllers enabling/disabling the same global FLAG_SECURE
/// window flag independently, as vault_controller/vault_entry_controller/
/// vault_setup_controller/vault_unlock_controller do in real onInit/onClose
/// pairs) is exercised as one continuous sequence rather than split across
/// isolated tests, to avoid fighting the shared reference count.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.optisec.mobile/screen_security');
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
      'reference-counts overlapping enable/disable pairs from multiple screens',
      () async {
    final service = ScreenSecurityService.instance;

    // Vault list screen becomes visible.
    await service.enable();
    expect(calls, ['enable']);

    // Entry detail screen opens on top -- also enables. The window flag is
    // already on, so this must not re-invoke the native channel.
    await service.enable();
    expect(calls, ['enable']);

    // Entry detail screen closes. The vault list underneath is still
    // visible and still wants protection -- must NOT turn it off.
    await service.disable();
    expect(calls, ['enable']);

    // Vault list screen closes too -- now it's really safe to turn off.
    await service.disable();
    expect(calls, ['enable', 'disable']);

    // An extra, unmatched disable() must not throw or invoke the channel
    // again.
    await service.disable();
    expect(calls, ['enable', 'disable']);

    // A fresh screen opening afterwards must re-enable normally.
    await service.enable();
    expect(calls, ['enable', 'disable', 'enable']);

    await service.disable();
    expect(calls, ['enable', 'disable', 'enable', 'disable']);
  });
}
