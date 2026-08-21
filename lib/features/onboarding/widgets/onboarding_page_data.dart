import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPageData {
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final IconData icon;
  final Color color;
  final List<OnboardingFeature> features;
  final List<OnboardingOrbitItem> orbitItems;

  const OnboardingPageData({
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.color,
    required this.features,
    required this.orbitItems,
  });
}

/// Identifies which localized string [OnboardingFeature.label] refers to. The raw
/// English text is only used as a lookup key here — the actual displayed
/// text comes from AppLocalizations, keyed by this enum, in the view.
enum OnboardingFeatureKey {
  realtimeThreatDetection,
  networkPrivacyProtection,
  cybersecurityEducation,
  evilTwinDetection,
  signalRiskAnalysis,
  connectedDeviceAudit,
  permissionAuditing,
  riskScoringPerApp,
  oneTapPermissionRevoke,
  handsOnLessons,
  knowledgeQuizzes,
  xpLevelsBadges,
}

class OnboardingFeature {
  final IconData icon;
  final OnboardingFeatureKey labelKey;
  const OnboardingFeature(this.icon, this.labelKey);
}

class OnboardingOrbitItem {
  final IconData icon;
  final Color color;
  final double angle; // radians
  const OnboardingOrbitItem(this.icon, this.color, this.angle);
}

const kOnboardingPages = [
  OnboardingPageData(
    title: 'Welcome to OptiSec',
    titleAr: 'مرحباً بك في OptiSec',
    description:
        'Your all-in-one security guardian. Monitor threats, protect your privacy, and build cyber skills — all in one place.',
    descriptionAr:
        'حارسك الأمني الشامل. راقب التهديدات وحافظ على خصوصيتك وطوّر مهاراتك الأمنية — كل ذلك في مكان واحد.',
    icon: Icons.security_rounded,
    color: AppColors.primary,
    features: [
      OnboardingFeature(Icons.radar_rounded, OnboardingFeatureKey.realtimeThreatDetection),
      OnboardingFeature(Icons.shield_rounded, OnboardingFeatureKey.networkPrivacyProtection),
      OnboardingFeature(Icons.school_rounded, OnboardingFeatureKey.cybersecurityEducation),
    ],
    orbitItems: [
      OnboardingOrbitItem(Icons.wifi_rounded, AppColors.info, 0.0),
      OnboardingOrbitItem(Icons.lock_rounded, AppColors.warning, 2.09),
      OnboardingOrbitItem(Icons.bug_report_rounded, AppColors.danger, 4.19),
    ],
  ),

  OnboardingPageData(
    title: 'Shield Your WiFi',
    titleAr: 'درِّع شبكتك اللاسلكية',
    description:
        'Scan any WiFi network in seconds. Detect evil twin attacks, rogue access points, and hidden network threats before they can do damage.',
    descriptionAr:
        'امسح أي شبكة واي فاي في ثوانٍ. اكتشف هجمات التوأم الشرير ونقاط الوصول المارقة والتهديدات الشبكية الخفية قبل أن تتسبب بالضرر.',
    icon: Icons.wifi_rounded,
    color: AppColors.info,
    features: [
      OnboardingFeature(Icons.wifi_tethering_error_rounded, OnboardingFeatureKey.evilTwinDetection),
      OnboardingFeature(Icons.signal_cellular_alt_rounded, OnboardingFeatureKey.signalRiskAnalysis),
      OnboardingFeature(Icons.devices_rounded, OnboardingFeatureKey.connectedDeviceAudit),
    ],
    orbitItems: [
      OnboardingOrbitItem(Icons.router_rounded, AppColors.info, 0.5),
      OnboardingOrbitItem(Icons.security_rounded, AppColors.primary, 2.6),
      OnboardingOrbitItem(Icons.warning_rounded, AppColors.danger, 4.7),
    ],
  ),

  OnboardingPageData(
    title: 'Guard Your Privacy',
    titleAr: 'احمِ خصوصيتك',
    description:
        'See exactly which apps have access to your camera, microphone, location, and contacts — and revoke permissions with one tap.',
    descriptionAr:
        'اعرف بالضبط أي التطبيقات تصل إلى كاميرتك وميكروفونك وموقعك وجهات اتصالك — وألغِ الأذونات بنقرة واحدة.',
    icon: Icons.shield_rounded,
    color: AppColors.safe,
    features: [
      OnboardingFeature(Icons.verified_user_rounded, OnboardingFeatureKey.permissionAuditing),
      OnboardingFeature(Icons.bar_chart_rounded, OnboardingFeatureKey.riskScoringPerApp),
      OnboardingFeature(Icons.touch_app_rounded, OnboardingFeatureKey.oneTapPermissionRevoke),
    ],
    orbitItems: [
      OnboardingOrbitItem(Icons.mic_rounded, AppColors.danger, 1.0),
      OnboardingOrbitItem(Icons.location_on_rounded, AppColors.warning, 3.1),
      OnboardingOrbitItem(Icons.camera_alt_rounded, AppColors.info, 5.2),
    ],
  ),

  OnboardingPageData(
    title: 'Master Cybersecurity',
    titleAr: 'أتقِن الأمن السيبراني',
    description:
        'Learn to defend yourself with bite-sized lessons, interactive quizzes, and real-world scenarios. Earn XP and unlock badges as you level up.',
    descriptionAr:
        'تعلم كيف تحمي نفسك بدروس مختصرة واختبارات تفاعلية وسيناريوهات واقعية. اكسب نقاط الخبرة وافتح الشارات مع تقدمك.',
    icon: Icons.school_rounded,
    color: AppColors.warning,
    features: [
      OnboardingFeature(Icons.menu_book_rounded, OnboardingFeatureKey.handsOnLessons),
      OnboardingFeature(Icons.quiz_rounded, OnboardingFeatureKey.knowledgeQuizzes),
      OnboardingFeature(Icons.emoji_events_rounded, OnboardingFeatureKey.xpLevelsBadges),
    ],
    orbitItems: [
      OnboardingOrbitItem(Icons.lock_rounded, AppColors.primary, 0.3),
      OnboardingOrbitItem(Icons.phishing_rounded, AppColors.danger, 2.4),
      OnboardingOrbitItem(Icons.emoji_events_rounded, AppColors.warning, 4.5),
    ],
  ),
];
