import 'package:get/get.dart';
import '../../../shared/models/lesson_model.dart';

class CyberAcademyController extends GetxController {
  // ── User progress ──────────────────────────────────────────────
  final userXp = 0.obs;
  final userLevel = 1.obs;
  final streak = 3.obs;

  int get xpForNextLevel => userLevel.value * 200;
  double get levelProgress =>
      (userXp.value % (userLevel.value * 200)) /
      (userLevel.value * 200).toDouble();

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
    _loadLessons();
  }

  void _loadLessons() {
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      lessons.assignAll(kDefaultLessons);
      isLoading.value = false;
    });
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
  void startLesson(LessonModel lesson) {
    activeLesson.value = lesson;
    activeStepIndex.value = 0;
    selectedQuizOption.value = -1;
    quizAnswered.value = false;

    final idx = lessons.indexWhere((l) => l.id == lesson.id);
    if (idx != -1 && lesson.status == LessonStatus.notStarted) {
      lessons[idx] =
          lesson.copyWith(status: LessonStatus.inProgress, progressPercent: 0);
    }
  }

  void nextStep() {
    final lesson = activeLesson.value;
    if (lesson == null) return;

    final next = activeStepIndex.value + 1;
    if (next >= lesson.steps.length) {
      _completeLesson(lesson);
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
    }
  }

  void answerQuiz(int optionIndex) {
    if (quizAnswered.value) return;
    selectedQuizOption.value = optionIndex;
    quizAnswered.value = true;
  }

  bool isAnswerCorrect(LessonStep step) =>
      selectedQuizOption.value == step.correctIndex;

  void _completeLesson(LessonModel lesson) {
    final idx = lessons.indexWhere((l) => l.id == lesson.id);
    if (idx != -1 && lessons[idx].status != LessonStatus.completed) {
      lessons[idx] =
          lesson.copyWith(status: LessonStatus.completed, progressPercent: 100);
      _awardXp(lesson.xpPoints);
      _checkBadges();
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
    while (userXp.value >= xpForNextLevel) {
      userLevel.value += 1;
    }
  }

  void _checkBadges() {
    if (completedCount >= 1 && !badges.contains('first_lesson')) {
      badges.add('first_lesson');
    }
    if (completedCount >= 3 && !badges.contains('apprentice')) {
      badges.add('apprentice');
    }
    if (completedCount >= totalCount && !badges.contains('graduate')) {
      badges.add('graduate');
    }
  }
}
