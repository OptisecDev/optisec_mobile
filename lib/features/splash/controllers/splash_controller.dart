import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../navigation/app_routes.dart';

class SplashController extends GetxController {
  final _box = GetStorage();

  // Drives the loading bar + status text in the view
  final loadingProgress = 0.0.obs;
  final statusIndex = 0.obs;

  static const _statusMessages = [
    'Initializing security engine…',
    'Loading threat database…',
    'Checking network interfaces…',
    'Calibrating privacy scanner…',
    'All systems ready',
  ];

  String get statusText => _statusMessages[statusIndex.value];

  @override
  void onReady() {
    super.onReady();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Tick the status text and progress bar in steps
    const steps = [
      (delay: 800,  progress: 0.20, status: 0),
      (delay: 1200, progress: 0.45, status: 1),
      (delay: 1600, progress: 0.65, status: 2),
      (delay: 2000, progress: 0.85, status: 3),
      (delay: 2400, progress: 1.00, status: 4),
    ];

    for (final step in steps) {
      await Future.delayed(Duration(milliseconds: step.delay));
      loadingProgress.value = step.progress;
      statusIndex.value = step.status;
    }

    await Future.delayed(const Duration(milliseconds: 600));
    _navigate();
  }

  void _navigate() {
    final seen = _box.read<bool>('onboarding_complete') ?? false;
    if (seen) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
