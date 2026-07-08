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
import '../features/subscription/views/paywall_view.dart';
import '../features/subscription/controllers/subscription_controller.dart';
import '../features/threat_intel/views/threat_intel_view.dart';
import '../features/threat_intel/controllers/threat_intel_controller.dart';
import '../features/app_lock/views/app_lock_settings_view.dart';
import '../features/app_lock/views/pin_setup_view.dart';
import '../features/app_lock/controllers/app_lock_controller.dart';
import '../features/app_lock/controllers/pin_setup_controller.dart';
import '../features/password_vault/controllers/vault_controller.dart';
import '../features/password_vault/controllers/vault_entry_controller.dart';
import '../features/password_vault/controllers/vault_setup_controller.dart';
import '../features/password_vault/controllers/vault_unlock_controller.dart';
import '../features/password_vault/views/vault_entry_detail_view.dart';
import '../features/password_vault/views/vault_entry_edit_view.dart';
import '../features/password_vault/views/vault_list_view.dart';
import '../features/password_vault/views/vault_setup_view.dart';
import '../features/password_vault/views/vault_unlock_view.dart';
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
        Get.lazyPut(() => SettingsController());
        Get.lazyPut(() => SubscriptionController());
        Get.lazyPut(() => ThreatIntelController());
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

    GetPage(
      name: AppRoutes.paywall,
      page: () => const PaywallView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => SubscriptionController()),
      ),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.threatIntel,
      page: () => const ThreatIntelView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ThreatIntelController()),
      ),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.appLock,
      page: () => const AppLockSettingsView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => AppLockController()),
      ),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinSetupView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => PinSetupController()),
      ),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.vault,
      page: () => const VaultListView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => VaultController()),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vaultSetup,
      page: () => const VaultSetupView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => VaultSetupController()),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vaultUnlock,
      page: () => const VaultUnlockView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => VaultUnlockController()),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vaultEntryDetail,
      page: () => const VaultEntryDetailView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => VaultEntryController()),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vaultEntryEdit,
      page: () => const VaultEntryEditView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => VaultEntryController()),
      ),
      transition: Transition.rightToLeft,
    ),
  ];
}
