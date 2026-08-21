import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/subscription/controllers/subscription_controller.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';

/// Regression test for the audit finding: license_key_view.dart and
/// subscription_controller.dart had zero Arabic support -- every error
/// message from activateLicenseKey() (surfaced via SubscriptionController's
/// private _messageFor()) was hardcoded English regardless of locale.
///
/// activateLicenseKey() is exercised directly against the real
/// LicenseKeyService.instance (the actual RSA verification path, untouched
/// by this fix) rather than onInit(), since onInit() would also kick off a
/// real in_app_purchase platform-channel query unrelated to what's being
/// verified here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SizedBox(),
      ),
    );
  }

  tearDown(() => Get.reset());

  testWidgets('a garbage key produces the English invalid-format message',
      (tester) async {
    await pump(tester, const Locale('en'));
    final c = SubscriptionController();

    final success = await c.activateLicenseKey('not-a-license-key-at-all');

    expect(success, isFalse);
    expect(c.licenseKeyError.value, "That doesn't look like a valid license key.");
  });

  testWidgets('a garbage key produces the Arabic invalid-format message',
      (tester) async {
    await pump(tester, const Locale('ar'));
    final c = SubscriptionController();

    final success = await c.activateLicenseKey('not-a-license-key-at-all');

    expect(success, isFalse);
    expect(c.licenseKeyError.value, 'هذا لا يبدو كمفتاح ترخيص صالح.');
  });

  testWidgets(
      'a well-formed but wrongly-signed key produces the Arabic tampered-signature message',
      (tester) async {
    await pump(tester, const Locale('ar'));
    final c = SubscriptionController();

    // Well-formed OPTM-PRO-<payload>.<signature> shape (a 256-byte signature
    // matches a real RSA-2048 signature's length), but not signed by the
    // real production key -- LicenseKeyService.instance must reject this as
    // an invalid signature, same as a tampered real key.
    final payload = base64Url.encode(utf8.encode('{"foo":"bar"}'));
    final fakeSignature = base64Url.encode(Uint8List(256));
    final success =
        await c.activateLicenseKey('OPTM-PRO-$payload.$fakeSignature');

    expect(success, isFalse);
    expect(c.licenseKeyError.value, 'هذا المفتاح غير صالح أو تم العبث به.');
  });
}
