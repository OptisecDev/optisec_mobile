import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../features/subscription/controllers/subscription_controller.dart';
import '../../../shared/models/lesson_model.dart';

class CyberAcademyController extends GetxController {
  final _box = GetStorage();

  static const _kUserXp = 'academy_user_xp';
  static const _kUserLevel = 'academy_user_level';
  static const _kBadges = 'academy_badges';
  static const _kLessonProgress = 'academy_lesson_progress';
  static const _kStreak = 'academy_streak';
  static const _kLastActiveDate = 'academy_last_active_date';

  // ── User progress ──────────────────────────────────────────────
  final userXp = 0.obs;
  final userLevel = 1.obs;
  final streak = 0.obs;

  int get xpForNextLevel => userLevel.value * 200;

  /// Cumulative XP needed to have reached [level]: each level costs more
  /// than the last (level L costs L*200 on top of the previous total), so
  /// this is the running sum 200 + 400 + ... + (level-1)*200.
  int _cumulativeXpToReach(int level) => 200 * (level - 1) * level ~/ 2;

  double get levelProgress {
    final xpIntoLevel = userXp.value - _cumulativeXpToReach(userLevel.value);
    return (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  // ── Lessons ────────────────────────────────────────────────────
  final lessons = <LessonModel>[].obs;
  final selectedCategory = Rx<LessonCategory?>(null);
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  // ── Active lesson / step ───────────────────────────────────────
  final activeLesson = Rx<LessonModel?>(null);
  final activeStepIndex = 0.obs;
  final selectedQuizOption = (-1).obs;
  final quizAnswered = false.obs;

  // ── Badges ─────────────────────────────────────────────────────
  final badges = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProgress();
    _loadLessons();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _loadProgress() {
    userXp.value = _box.read<int>(_kUserXp) ?? 0;
    userLevel.value = _box.read<int>(_kUserLevel) ?? 1;
    badges.assignAll(
      (_box.read<List>(_kBadges) ?? const []).cast<String>(),
    );

    final savedStreak = _box.read<int>(_kStreak) ?? 0;
    final lastActive = _box.read<String>(_kLastActiveDate);
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    // A streak with a gap of more than one day is broken -- don't keep
    // showing a stale count as if it were still active.
    streak.value =
        (lastActive == today || lastActive == yesterday) ? savedStreak : 0;
  }

  /// Called once a lesson is genuinely completed (not just opened), so the
  /// streak reflects real daily engagement rather than a screen visit.
  void _recordActivityForStreak() {
    final today = _dateKey(DateTime.now());
    final lastActive = _box.read<String>(_kLastActiveDate);
    if (lastActive == today) return; // already counted today

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    streak.value = (lastActive == yesterday) ? streak.value + 1 : 1;
    _box.write(_kStreak, streak.value);
    _box.write(_kLastActiveDate, today);
  }

  void _loadLessons() {
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      final saved = Map<String, dynamic>.from(
        _box.read<Map>(_kLessonProgress) ?? const {},
      );
      lessons.assignAll(kDefaultLessons.map((lesson) {
        final entry = saved[lesson.id];
        if (entry == null) return lesson;
        final map = Map<String, dynamic>.from(entry as Map);
        return lesson.copyWith(
          status: LessonStatus.values.byName(map['status'] as String),
          progressPercent: map['progressPercent'] as int,
        );
      }).toList());
      isLoading.value = false;
    });
  }

  void _persistLessonProgress() {
    final map = {
      for (final l in lessons)
        if (l.status != LessonStatus.notStarted)
          l.id: {'status': l.status.name, 'progressPercent': l.progressPercent},
    };
    _box.write(_kLessonProgress, map);
  }

  // ── Filtering ──────────────────────────────────────────────────
  List<LessonModel> get filteredLessons {
    var list = lessons.toList();
    if (selectedCategory.value != null) {
      list = list.where((l) => l.category == selectedCategory.value).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((l) =>
              l.titleEn.toLowerCase().contains(q) ||
              l.titleAr.contains(q) ||
              l.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  List<LessonModel> get featuredLessons {
    final inProgress =
        lessons.where((l) => l.status == LessonStatus.inProgress).toList();
    if (inProgress.isNotEmpty) return inProgress.take(2).toList();
    return lessons
        .where((l) => l.status == LessonStatus.notStarted)
        .take(2)
        .toList();
  }

  LessonModel? get continueLessonCandidate =>
      lessons.firstWhereOrNull((l) => l.status == LessonStatus.inProgress);

  void setCategory(LessonCategory? cat) => selectedCategory.value = cat;

  void setSearch(String q) => searchQuery.value = q;

  // ── Stats ──────────────────────────────────────────────────────
  int get completedCount =>
      lessons.where((l) => l.status == LessonStatus.completed).length;

  int get totalCount => lessons.length;

  double get overallProgress =>
      lessons.isEmpty ? 0 : completedCount / totalCount;

  // ── Lesson flow ────────────────────────────────────────────────
  /// Returns `false` (and prompts the paywall) for an advanced lesson on a
  /// free account, without touching lesson/progress state -- callers must
  /// check the return value before presenting the lesson UI.
  bool startLesson(LessonModel lesson) {
    if (lesson.difficulty == Difficulty.advanced &&
        !Get.find<SubscriptionController>()
            .checkAccessOrPrompt(feature: 'Advanced lessons')) {
      return false;
    }

    activeLesson.value = lesson;
    activeStepIndex.value = 0;
    selectedQuizOption.value = -1;
    quizAnswered.value = false;

    final idx = lessons.indexWhere((l) => l.id == lesson.id);
    if (idx != -1 && lesson.status == LessonStatus.notStarted) {
      lessons[idx] =
          lesson.copyWith(status: LessonStatus.inProgress, progressPercent: 0);
      _persistLessonProgress();
    }
    return true;
  }

  void nextStep() {
    final lesson = activeLesson.value;
    if (lesson == null) return;

    final next = activeStepIndex.value + 1;
    if (next >= lesson.steps.length) {
      completeLesson(lesson);
      return;
    }

    activeStepIndex.value = next;
    selectedQuizOption.value = -1;
    quizAnswered.value = false;

    final progress = ((next / lesson.steps.length) * 100).round();
    final idx = lessons.indexWhere((l) => l.id == lesson.id);
    if (idx != -1) {
      lessons[idx] = lessons[idx]
          .copyWith(status: LessonStatus.inProgress, progressPercent: progress);
      _persistLessonProgress();
    }
  }

  void answerQuiz(int optionIndex) {
    if (quizAnswered.value) return;
    selectedQuizOption.value = optionIndex;
    quizAnswered.value = true;
  }

  bool isAnswerCorrect(LessonStep step) =>
      selectedQuizOption.value == step.correctIndex;

  void completeLesson(LessonModel lesson) {
    final idx = lessons.indexWhere((l) => l.id == lesson.id);
    if (idx != -1 && lessons[idx].status != LessonStatus.completed) {
      lessons[idx] =
          lesson.copyWith(status: LessonStatus.completed, progressPercent: 100);
      _persistLessonProgress();
      _awardXp(lesson.xpPoints);
      _checkBadges();
      _recordActivityForStreak();
    }
    closeLesson();
  }

  void closeLesson() {
    activeLesson.value = null;
    activeStepIndex.value = 0;
    selectedQuizOption.value = -1;
    quizAnswered.value = false;
  }

  void _awardXp(int points) {
    userXp.value += points;
    while (userXp.value >= _cumulativeXpToReach(userLevel.value + 1)) {
      userLevel.value += 1;
    }
    _box.write(_kUserXp, userXp.value);
    _box.write(_kUserLevel, userLevel.value);
  }

  void _checkBadges() {
    var changed = false;
    if (completedCount >= 1 && !badges.contains('first_lesson')) {
      badges.add('first_lesson');
      changed = true;
    }
    if (completedCount >= 3 && !badges.contains('apprentice')) {
      badges.add('apprentice');
      changed = true;
    }
    if (completedCount >= totalCount && !badges.contains('graduate')) {
      badges.add('graduate');
      changed = true;
    }
    if (changed) _box.write(_kBadges, badges.toList());
  }
}
