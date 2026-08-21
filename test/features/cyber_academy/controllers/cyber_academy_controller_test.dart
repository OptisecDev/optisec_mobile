import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optisec_mobile/features/cyber_academy/controllers/cyber_academy_controller.dart';
import 'package:optisec_mobile/shared/models/lesson_model.dart';

/// GetStorage needs a real documents-directory path even under `flutter
/// test`, so path_provider's channel is mocked to a throwaway temp dir.
/// These are plain test() (not testWidgets()), so real Future.delayed calls
/// (the controller's simulated lesson-loading delay) work without needing
/// to escape a fake-async clock.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDir =
      Directory.systemTemp.createTempSync('cyber_academy_controller_test');
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

  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<CyberAcademyController> makeController() async {
    final c = CyberAcademyController();
    c.onInit();
    await Future.delayed(const Duration(milliseconds: 450));
    return c;
  }

  /// phishing_101 is a real default lesson: beginner difficulty (so
  /// completeLesson never touches SubscriptionController), 60 XP.
  LessonModel beginnerLesson(CyberAcademyController c) =>
      c.lessons.firstWhere((l) => l.id == 'phishing_101');

  group('levelProgress', () {
    test('is 0% immediately after leveling up (not 50%, per the audit example)',
        () async {
      final c = await makeController();
      // Exact scenario from the audit report: level 1, earn 200 XP, level
      // up to 2. Simulate the post-level-up state directly.
      c.userLevel.value = 2;
      c.userXp.value = 200;

      expect(c.levelProgress, 0.0);
    });

    test('grows correctly within a level and resets to 0% at the next level-up',
        () async {
      final c = await makeController();

      c.userLevel.value = 2;
      c.userXp.value = 400; // halfway through level 2's 400 xp requirement
      expect(c.levelProgress, closeTo(0.5, 0.001));

      c.userLevel.value = 3;
      c.userXp.value = 600; // exactly the level-3 threshold
      expect(c.levelProgress, 0.0); // must reset again, not compound
    });
  });

  group('persistence', () {
    test('userXp, userLevel, and badges survive across controller instances',
        () async {
      final c1 = await makeController();
      final lesson = beginnerLesson(c1);
      c1.completeLesson(lesson);

      expect(c1.userXp.value, 60);
      expect(c1.badges, contains('first_lesson'));

      final c2 = await makeController();
      expect(c2.userXp.value, 60);
      expect(c2.userLevel.value, c1.userLevel.value);
      expect(c2.badges, contains('first_lesson'));
    });

    test('a completed lesson\'s status survives across controller instances',
        () async {
      final c1 = await makeController();
      c1.completeLesson(beginnerLesson(c1));

      final c2 = await makeController();
      final reloaded = c2.lessons.firstWhere((l) => l.id == 'phishing_101');
      expect(reloaded.status, LessonStatus.completed);
      expect(reloaded.progressPercent, 100);
    });
  });

  group('streak', () {
    test('completing a lesson for the first time ever starts the streak at 1',
        () async {
      final c = await makeController();
      c.completeLesson(beginnerLesson(c));

      expect(c.streak.value, 1);
    });

    test('completing a lesson the day after the last one extends the streak',
        () async {
      final yesterday = dateKey(DateTime.now().subtract(const Duration(days: 1)));
      GetStorage().write('academy_last_active_date', yesterday);
      GetStorage().write('academy_streak', 5);

      final c = await makeController();
      expect(c.streak.value, 5); // still shown as alive on load

      c.completeLesson(beginnerLesson(c));
      expect(c.streak.value, 6);
    });

    test('a gap of more than one day resets the streak instead of extending it',
        () async {
      final threeDaysAgo =
          dateKey(DateTime.now().subtract(const Duration(days: 3)));
      GetStorage().write('academy_last_active_date', threeDaysAgo);
      GetStorage().write('academy_streak', 5);

      final c = await makeController();
      // Broken streak must not still show the stale count.
      expect(c.streak.value, 0);

      c.completeLesson(beginnerLesson(c));
      expect(c.streak.value, 1);
    });

    test('completing a second lesson the same day does not double-count',
        () async {
      final c = await makeController();
      c.completeLesson(beginnerLesson(c));
      expect(c.streak.value, 1);

      final second = c.lessons.firstWhere((l) => l.id == 'password_101');
      c.completeLesson(second);
      expect(c.streak.value, 1);
    });
  });
}
