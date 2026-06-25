import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPageData {
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final IconData icon;
  final Color color;
  final List<_Feature> features;
  final List<_OrbitItem> orbitItems;

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

class _Feature {
  final IconData icon;
  final String label;
  const _Feature(this.icon, this.label);
}

class _OrbitItem {
  final IconData icon;
  final Color color;
  final double angle; // radians
  const _OrbitItem(this.icon, this.color, this.angle);
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
      _Feature(Icons.radar_rounded, 'Real-time threat detection'),
      _Feature(Icons.shield_rounded, 'Network & privacy protection'),
      _Feature(Icons.school_rounded, 'Cybersecurity education'),
    ],
    orbitItems: [
      _OrbitItem(Icons.wifi_rounded, AppColors.info, 0.0),
      _OrbitItem(Icons.lock_rounded, AppColors.warning, 2.09),
      _OrbitItem(Icons.bug_report_rounded, AppColors.danger, 4.19),
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
      _Feature(Icons.wifi_tethering_error_rounded, 'Evil Twin detection'),
      _Feature(Icons.signal_cellular_alt_rounded, 'Signal & risk analysis'),
      _Feature(Icons.devices_rounded, 'Connected device audit'),
    ],
    orbitItems: [
      _OrbitItem(Icons.router_rounded, AppColors.info, 0.5),
      _OrbitItem(Icons.security_rounded, AppColors.primary, 2.6),
      _OrbitItem(Icons.warning_rounded, AppColors.danger, 4.7),
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
      _Feature(Icons.verified_user_rounded, 'Permission auditing'),
      _Feature(Icons.bar_chart_rounded, 'Risk scoring per app'),
      _Feature(Icons.touch_app_rounded, 'One-tap permission revoke'),
    ],
    orbitItems: [
      _OrbitItem(Icons.mic_rounded, AppColors.danger, 1.0),
      _OrbitItem(Icons.location_on_rounded, AppColors.warning, 3.1),
      _OrbitItem(Icons.camera_alt_rounded, AppColors.info, 5.2),
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
      _Feature(Icons.menu_book_rounded, '8+ hands-on lessons'),
      _Feature(Icons.quiz_rounded, 'Knowledge quizzes'),
      _Feature(Icons.emoji_events_rounded, 'XP, levels & badges'),
    ],
    orbitItems: [
      _OrbitItem(Icons.lock_rounded, AppColors.primary, 0.3),
      _OrbitItem(Icons.phishing_rounded, AppColors.danger, 2.4),
      _OrbitItem(Icons.emoji_events_rounded, AppColors.warning, 4.5),
    ],
  ),
];
