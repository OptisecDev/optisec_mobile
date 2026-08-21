import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optisec_mobile/features/dashboard/controllers/dashboard_controller.dart';

/// Constructed directly (never via Get.put), so its real onInit() -- which
/// needs WifiShieldController and PrivacyGuardController registered -- never
/// runs. clearHistory() doesn't touch either, so this is enough to exercise
/// it in isolation. GetStorage still needs path_provider mocked to a
/// throwaway temp dir even under `flutter test`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDir =
      Directory.systemTemp.createTempSync('dashboard_controller_test');
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

  setUp(() async {
    await GetStorage().erase();
  });

  group('clearHistory', () {
    test('removes the persisted daily history entry', () {
      GetStorage().write('dashboard_daily_history', {
        '2026-08-19': {'overall': 80, 'threats': 1},
      });

      DashboardController().clearHistory();

      expect(GetStorage().read('dashboard_daily_history'), isNull);
    });

    test('resets the visible score/threat history to empty', () {
      final controller = DashboardController();
      controller.scoreHistory.value = [10, 20, 30, 40, 50, 60, 70];
      controller.threatHistory.value = [1, 2, 3, 4, 5, 6, 7];

      controller.clearHistory();

      expect(controller.scoreHistory, everyElement(0));
      expect(controller.threatHistory, everyElement(0));
      expect(controller.scoreHistory, hasLength(7));
      expect(controller.threatHistory, hasLength(7));
    });
  });
}
