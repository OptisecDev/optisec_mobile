import 'package:get/get.dart';
import '../features/splash/views/splash_view.dart';
import '../features/splash/controllers/splash_controller.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/onboarding/controllers/onboarding_controller.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/wifi_shield/controllers/wifi_shield_controller.dart';
import '../features/privacy_guard/controllers/privacy_guard_controller.dart';
import '../features/cyber_academy/controllers/cyber_academy_controller.dart';
import '../features/settings/views/settings_view.dart';
import '../features/settings/controllers/settings_controller.dart';
import '../shared/widgets/app_shell.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SplashController())),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => OnboardingController()),
      ),
      transition: Transition.fadeIn,
    ),

    // ── Shell: registers all tab controllers in one binding ─────────
    GetPage(
      name: AppRoutes.home,
      page: () => const AppShell(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => DashboardController());
        Get.lazyPut(() => WifiShieldController());
        Get.lazyPut(() => PrivacyGuardController());
        Get.lazyPut(() => CyberAcademyController());
      }),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SettingsController()),
      ),
      transition: Transition.rightToLeft,
    ),
  ];
}
