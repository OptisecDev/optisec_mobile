import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/subscription/controllers/subscription_controller.dart';
import 'package:optisec_mobile/features/subscription/views/paywall_view.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';

/// Regression test for the audit finding: Subscription was one of seven
/// modules with zero AppLocalizations usage. paywall_view.dart's benefit
/// list, "Restore Purchases", and "Continue" button were all hardcoded
/// English regardless of locale; this verifies they render Arabic text
/// under the Arabic locale, and that the hardcoded English strings the
/// audit flagged are actually gone.
///
/// _StubSubscriptionController skips the real onInit() (which would fire a
/// real in_app_purchase platform-channel query) -- PaywallView only reads
/// isLoading/products, both of which are safe field-initializer defaults
/// (false/empty) without onInit ever running.
class _StubSubscriptionController extends SubscriptionController {
  @override
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => Get.reset());

  Future<void> pump(WidgetTester tester) async {
    Get.put<SubscriptionController>(_StubSubscriptionController());
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PaywallView(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the benefits list and buttons in Arabic', (tester) async {
    await pump(tester);

    expect(find.text('فحوصات واي فاي غير محدودة'), findsOneWidget); // reused wifi key
    expect(find.text('تحليل كامل لهجمات Evil Twin'), findsOneWidget);
    expect(find.text('تقارير PDF أسبوعية'), findsOneWidget);
    expect(find.text('جميع دروس أكاديمية الأمن السيبراني'), findsOneWidget);
    expect(find.text('تنبيهات ذات أولوية'), findsOneWidget);
    expect(find.text('استعادة المشتريات'), findsOneWidget);
    expect(find.text('هل لديك مفتاح ترخيص؟'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
  });

  testWidgets('the old hardcoded English strings are gone', (tester) async {
    await pump(tester);

    expect(find.text('Restore Purchases'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Unlimited WiFi scans'), findsNothing);
    expect(find.text('Priority alerts'), findsNothing);
  });
}
