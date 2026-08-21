import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optisec_mobile/features/dashboard/controllers/dashboard_controller.dart';
import 'package:optisec_mobile/features/privacy_guard/controllers/privacy_guard_controller.dart';
import 'package:optisec_mobile/features/wifi_shield/controllers/wifi_shield_controller.dart';
import 'package:optisec_mobile/shared/models/wifi_network_model.dart';

/// _recomputeScore() (private, so only reachable through DashboardController's
/// real onInit()/everAll() wiring -- not callable directly from this file)
/// used to let an older, slower-resolving call overwrite a newer, already-
/// finished one because nothing tracked which call was most recent. These
/// stubs skip the real onInit() of WifiShieldController/PrivacyGuardController
/// (which would otherwise kick off real platform-channel scans) and let the
/// test drive the exact risk-relevant getters DashboardController reads.
class _StubWifiShieldController extends WifiShieldController {
  @override
  void onInit() {}

  @override
  int get overallRisk => 10;

  @override
  List<WifiNetworkModel> get evilTwins => const [];

  @override
  WifiNetworkModel? get connectedNetwork => null;

  @override
  int get safeCount => 0;

  @override
  int get threatCount => 0;
}

class _StubPrivacyGuardController extends PrivacyGuardController {
  @override
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDir = Directory.systemTemp.createTempSync('dashboard_race_test');
  const pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (call) async {
    if (call.method == 'getApplicationDocumentsDirectory') return tempDir.path;
    return null;
  });

  const appLockChannel = MethodChannel('com.optisec.mobile/app_lock');
  // When non-null, every app_lock channel call blocks on this until the
  // test completes it -- used to hold one _recomputeScore() call "in
  // flight" past the point where a second, later-triggered one finishes.
  Completer<void>? blocker;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(appLockChannel, (call) async {
    if (blocker != null) await blocker!.future;
    switch (call.method) {
      case 'isPinSet':
        return true;
      case 'getLockedApps':
        return <String>[];
      case 'isMonitorServiceRunning':
        return false;
    }
    return null;
  });

  setUpAll(() async {
    await GetStorage.init();
  });

  setUp(() async {
    await GetStorage().erase();
  });

  tearDown(() {
    blocker = null;
    Get.reset();
  });

  test(
      'an older overlapping recompute does not overwrite a newer one\'s result',
      () async {
    Get.put<WifiShieldController>(_StubWifiShieldController());
    final privacy = Get.put<PrivacyGuardController>(_StubPrivacyGuardController());
    privacy.privacyScore.value = 10; // initial state for onInit()'s own recompute

    final dashboard = Get.put(DashboardController());
    // Let onInit()'s own unawaited _recomputeScore() call finish before
    // orchestrating the two overlapping calls below.
    await Future.delayed(const Duration(milliseconds: 10));

    // Recompute #1 ("stale"): privacyScore=20, but its app_lock channel
    // calls will be held open by `blocker`.
    blocker = Completer<void>();
    privacy.privacyScore.value = 20;
    // Let it run its synchronous prefix and reach (and block on) its first
    // app_lock channel call.
    await Future.delayed(Duration.zero);

    // Recompute #2 ("fresh"): privacyScore=90, its channel calls resolve
    // immediately since a fresh (null) blocker is captured per-call.
    final freshBlocker = blocker;
    blocker = null;
    privacy.privacyScore.value = 90;
    // Let recompute #2 run to completion, including all of its awaits.
    await Future.delayed(const Duration(milliseconds: 10));

    expect(dashboard.score.value.privacyScore, 90);

    // Now release recompute #1's blocked channel call. It should discover
    // it's stale and discard its result instead of overwriting #2's.
    freshBlocker!.complete();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(dashboard.score.value.privacyScore, 90);
  });
}
