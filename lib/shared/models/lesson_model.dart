enum LessonStatus { notStarted, inProgress, completed }

enum LessonCategory { phishing, password, network, privacy }

enum Difficulty { beginner, intermediate, advanced }

class QuizOption {
  final String text;
  const QuizOption(this.text);
}

class LessonStep {
  final String title;
  final String content;
  final bool isQuiz;
  final List<QuizOption> options;
  final int correctIndex;

  const LessonStep({
    required this.title,
    required this.content,
    this.isQuiz = false,
    this.options = const [],
    this.correctIndex = 0,
  });
}

class LessonModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final LessonCategory category;
  final LessonStatus status;
  final int durationMinutes;
  final int progressPercent;
  final String iconAsset;
  final Difficulty difficulty;
  final int xpPoints;
  final List<String> tags;
  final List<LessonStep> steps;

  const LessonModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.category,
    required this.status,
    required this.durationMinutes,
    required this.progressPercent,
    required this.iconAsset,
    this.difficulty = Difficulty.beginner,
    this.xpPoints = 50,
    this.tags = const [],
    this.steps = const [],
  });

  LessonModel copyWith({
    LessonStatus? status,
    int? progressPercent,
  }) {
    return LessonModel(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      category: category,
      status: status ?? this.status,
      durationMinutes: durationMinutes,
      progressPercent: progressPercent ?? this.progressPercent,
      iconAsset: iconAsset,
      difficulty: difficulty,
      xpPoints: xpPoints,
      tags: tags,
      steps: steps,
    );
  }
}

const List<LessonModel> kDefaultLessons = [
  LessonModel(
    id: 'phishing_101',
    titleEn: 'Phishing Awareness',
    titleAr: 'التوعية بالتصيد الاحتيالي',
    descriptionEn: 'Learn to identify and avoid phishing attacks.',
    descriptionAr: 'تعلم كيفية التعرف على هجمات التصيد الاحتيالي وتجنبها.',
    category: LessonCategory.phishing,
    status: LessonStatus.notStarted,
    durationMinutes: 10,
    progressPercent: 0,
    iconAsset: 'assets/icons/phishing.png',
    difficulty: Difficulty.beginner,
    xpPoints: 60,
    tags: ['email', 'social engineering', 'links'],
    steps: [
      LessonStep(
        title: 'What Is Phishing?',
        content:
            'Phishing is a cyberattack where criminals impersonate trusted entities — banks, services, or colleagues — via email, SMS, or fake websites to steal your credentials or install malware.\n\nOver 3.4 billion phishing emails are sent every day. It\'s the #1 attack vector worldwide.',
      ),
      LessonStep(
        title: 'Red Flags in Emails',
        content:
            'Watch for these warning signs:\n\n• Urgent or threatening language ("Your account will be closed!")\n• Mismatched sender address (support@paypa1.com)\n• Generic greetings ("Dear Customer")\n• Suspicious links that don\'t match the claimed sender\n• Unexpected attachments\n\nAlways hover over links before clicking to reveal the real destination.',
      ),
      LessonStep(
        title: 'Quick Check',
        content: 'An email says: "Click here immediately or your account is suspended." It comes from "security@g00gle.com". What should you do?',
        isQuiz: true,
        options: [
          QuizOption('Click the link and log in immediately'),
          QuizOption('Forward it to your contacts to warn them'),
          QuizOption('Delete it and report it as phishing'),
          QuizOption('Reply and ask if it\'s real'),
        ],
        correctIndex: 2,
      ),
      LessonStep(
        title: 'How to Protect Yourself',
        content:
            'Three key defenses:\n\n1. Enable Multi-Factor Authentication (MFA) — even if your password is stolen, attackers can\'t log in.\n\n2. Use a password manager — it auto-fills only on the real domain, blocking fake sites.\n\n3. Report phishing — use the "Report Phishing" button in Gmail or Outlook. You protect everyone.',
      ),
    ],
  ),

  LessonModel(
    id: 'password_101',
    titleEn: 'Password Security',
    titleAr: 'أمان كلمة المرور',
    descriptionEn: 'Create and manage strong passwords.',
    descriptionAr: 'إنشاء وإدارة كلمات مرور قوية.',
    category: LessonCategory.password,
    status: LessonStatus.notStarted,
    durationMinutes: 8,
    progressPercent: 0,
    iconAsset: 'assets/icons/password.png',
    difficulty: Difficulty.beginner,
    xpPoints: 50,
    tags: ['passwords', '2FA', 'accounts'],
    steps: [
      LessonStep(
        title: 'Why Passwords Fail',
        content:
            'Most people use weak passwords that are cracked in seconds:\n\n• "123456" is cracked instantly\n• "password" is cracked instantly\n• "john1987" takes about 3 minutes\n\nData breaches expose billions of passwords each year. If you reuse one password, a single breach exposes all your accounts.',
      ),
      LessonStep(
        title: 'What Makes a Strong Password',
        content:
            'A strong password has:\n\n✓ At least 16 characters\n✓ Mix of uppercase, lowercase, numbers, symbols\n✓ No dictionary words or personal info\n✓ Unique for every account\n\nBest approach: use a passphrase — a random string of 4–5 unrelated words like "correct-horse-battery-staple" — long, memorable, and very hard to crack.',
      ),
      LessonStep(
        title: 'Knowledge Check',
        content: 'Which of these is the strongest password?',
        isQuiz: true,
        options: [
          QuizOption('P@ssw0rd123'),
          QuizOption('Ahmed1990!'),
          QuizOption('xK#9mQ\$vLp2!nRt8'),
          QuizOption('ilovemydog'),
        ],
        correctIndex: 2,
      ),
      LessonStep(
        title: 'Password Managers',
        content:
            'A password manager generates and stores unique, complex passwords for every site. You only need to remember one master password.\n\nRecommended: Bitwarden (free, open-source), 1Password, or the built-in manager in your browser.\n\nEnable biometric unlock for fast, safe access on mobile.',
      ),
    ],
  ),

  LessonModel(
    id: 'network_101',
    titleEn: 'Network Security',
    titleAr: 'أمان الشبكة',
    descriptionEn: 'Understand threats on public WiFi networks.',
    descriptionAr: 'فهم التهديدات على شبكات الواي فاي العامة.',
    category: LessonCategory.network,
    status: LessonStatus.notStarted,
    durationMinutes: 12,
    progressPercent: 0,
    iconAsset: 'assets/icons/network.png',
    difficulty: Difficulty.intermediate,
    xpPoints: 80,
    tags: ['wifi', 'VPN', 'MITM', 'encryption'],
    steps: [
      LessonStep(
        title: 'Public WiFi Risks',
        content:
            'Open WiFi networks — cafés, airports, hotels — transmit data without encryption. Anyone on the same network can intercept your traffic using freely available tools.\n\nCommon attacks on public WiFi:\n• Man-in-the-Middle (MITM)\n• Evil Twin (fake AP)\n• Packet sniffing\n• Session hijacking',
      ),
      LessonStep(
        title: 'Evil Twin Attacks',
        content:
            'An attacker creates a rogue access point with the same SSID as a legitimate network. Your device connects automatically and all traffic passes through the attacker.\n\nSigns you might be on an evil twin:\n• Captive portal asks for account credentials\n• SSL certificate errors appear\n• Pages load unusually slowly\n\nOptiSec\'s WiFi Shield detects evil twins by comparing MAC vendor prefixes (OUI).',
      ),
      LessonStep(
        title: 'Scenario',
        content: 'You\'re at an airport. You see two networks: "Airport_Free_WiFi" (open) and "Airport_Free_WiFi_5G" (open). What\'s the safest approach?',
        isQuiz: true,
        options: [
          QuizOption('Connect to whichever has the strongest signal'),
          QuizOption('Use your phone\'s mobile data instead and avoid both'),
          QuizOption('Connect to the 5G one — it\'s newer technology'),
          QuizOption('Ask the nearest person which one is real'),
        ],
        correctIndex: 1,
      ),
      LessonStep(
        title: 'Staying Safe on WiFi',
        content:
            'Best practices:\n\n1. Use a VPN — encrypts all traffic so even the network operator can\'t read it.\n2. Prefer HTTPS sites — look for the padlock icon.\n3. Disable auto-connect — stop your device joining unknown networks.\n4. Use mobile data for banking — never use public WiFi for financial transactions.\n5. Turn off WiFi when not in use.',
      ),
    ],
  ),

  LessonModel(
    id: 'privacy_101',
    titleEn: 'Data Privacy',
    titleAr: 'خصوصية البيانات',
    descriptionEn: 'Protect your personal data on mobile.',
    descriptionAr: 'حماية بياناتك الشخصية على الجوال.',
    category: LessonCategory.privacy,
    status: LessonStatus.notStarted,
    durationMinutes: 10,
    progressPercent: 0,
    iconAsset: 'assets/icons/privacy.png',
    difficulty: Difficulty.beginner,
    xpPoints: 60,
    tags: ['permissions', 'apps', 'data'],
    steps: [
      LessonStep(
        title: 'Your Data Is Valuable',
        content:
            'Apps collect far more than you think:\n\n• Location history → reveals your home, work, habits\n• Contacts → exposes everyone in your network\n• Microphone access → can record conversations\n• Call history → reveals your relationships\n\nData brokers buy and sell this information. A single app\'s data breach can expose years of personal history.',
      ),
      LessonStep(
        title: 'The Permission Audit',
        content:
            'Perform a monthly permission audit:\n\n1. Go to Settings → Privacy → Permission Manager\n2. Review each permission category\n3. Remove any app that doesn\'t need that permission for its core function\n\nKey question: "Does a flashlight app really need microphone access?" If the answer is no — revoke it immediately.',
      ),
      LessonStep(
        title: 'Quiz Time',
        content: 'A flashlight app requests access to your microphone, contacts, and location. What should you do?',
        isQuiz: true,
        options: [
          QuizOption('Grant all permissions — the app might need them'),
          QuizOption('Grant only location since that might help with brightness'),
          QuizOption('Deny all three and use the app anyway, or uninstall it'),
          QuizOption('Grant microphone only'),
        ],
        correctIndex: 2,
      ),
      LessonStep(
        title: 'Privacy Hardening Checklist',
        content:
            'Apply these now:\n\n✓ Review app permissions monthly\n✓ Use "Only while using" for location\n✓ Disable ad tracking (Settings → Privacy → Tracking)\n✓ Encrypt your device storage\n✓ Use a private DNS (e.g. 1.1.1.1 or NextDNS)\n✓ Prefer open-source apps when available\n✓ Read privacy policies before installing new apps',
      ),
    ],
  ),

  LessonModel(
    id: 'social_engineering_201',
    titleEn: 'Social Engineering Tactics',
    titleAr: 'أساليب الهندسة الاجتماعية',
    descriptionEn: 'Recognize manipulation used by attackers.',
    descriptionAr: 'تعرف على أساليب التلاعب التي يستخدمها المهاجمون.',
    category: LessonCategory.phishing,
    status: LessonStatus.notStarted,
    durationMinutes: 14,
    progressPercent: 0,
    iconAsset: 'assets/icons/phishing.png',
    difficulty: Difficulty.intermediate,
    xpPoints: 90,
    tags: ['manipulation', 'pretexting', 'vishing'],
    steps: [
      LessonStep(
        title: 'Beyond Email Phishing',
        content:
            'Social engineering exploits human psychology, not software vulnerabilities. Attackers use:\n\n• Vishing — voice calls impersonating banks or IT support\n• Smishing — SMS messages with malicious links\n• Pretexting — fabricated scenarios to extract information\n• Baiting — infected USB drives left in public places',
      ),
      LessonStep(
        title: 'Psychological Triggers',
        content:
            'Attackers exploit these mental biases:\n\n• Authority — "I\'m calling from your bank\'s fraud department"\n• Urgency — "You must act NOW or lose access"\n• Scarcity — "This is your only chance"\n• Social proof — "All your colleagues already did this"\n• Reciprocity — they do you a favour first, then ask for something',
      ),
      LessonStep(
        title: 'Identify the Attack',
        content: 'You receive a call: "This is Microsoft Support. We detected a virus on your PC. I need remote access to fix it now." What\'s happening?',
        isQuiz: true,
        options: [
          QuizOption('A genuine Microsoft support call — give access'),
          QuizOption('A vishing / tech support scam — hang up immediately'),
          QuizOption('A prank call — just ignore it'),
          QuizOption('A legitimate security scan — cooperate'),
        ],
        correctIndex: 1,
      ),
    ],
  ),

  LessonModel(
    id: 'encryption_201',
    titleEn: 'Encryption Fundamentals',
    titleAr: 'أساسيات التشفير',
    descriptionEn: 'How encryption protects your data in transit and at rest.',
    descriptionAr: 'كيف يحمي التشفير بياناتك أثناء النقل وفي الراحة.',
    category: LessonCategory.network,
    status: LessonStatus.notStarted,
    durationMinutes: 15,
    progressPercent: 0,
    iconAsset: 'assets/icons/network.png',
    difficulty: Difficulty.advanced,
    xpPoints: 120,
    tags: ['TLS', 'HTTPS', 'end-to-end', 'VPN'],
    steps: [
      LessonStep(
        title: 'What Encryption Does',
        content:
            'Encryption converts readable data (plaintext) into an unreadable format (ciphertext) using a mathematical key. Only someone with the correct key can decrypt it.\n\nTwo types matter most:\n• Encryption in transit — protects data moving over networks (HTTPS, TLS)\n• Encryption at rest — protects stored data on your device',
      ),
      LessonStep(
        title: 'HTTPS and TLS',
        content:
            'When you see the padlock in your browser, TLS is active. TLS 1.3 (current) provides:\n\n• Mutual authentication (server proves its identity)\n• Forward secrecy (past sessions stay safe if a key is later compromised)\n• Encryption of all content, headers, and metadata\n\nAvoid any site that uses HTTP (no padlock) for anything sensitive.',
      ),
      LessonStep(
        title: 'VPNs and What They Do',
        content: 'A VPN encrypts all traffic between your device and the VPN server. Which of these does a VPN NOT protect against?',
        isQuiz: true,
        options: [
          QuizOption('Someone sniffing your café WiFi traffic'),
          QuizOption('Your ISP seeing which sites you visit'),
          QuizOption('Malware already installed on your device'),
          QuizOption('A rogue WiFi access point intercepting packets'),
        ],
        correctIndex: 2,
      ),
    ],
  ),

  LessonModel(
    id: '2fa_101',
    titleEn: 'Two-Factor Authentication',
    titleAr: 'المصادقة الثنائية',
    descriptionEn: 'Secure your accounts with a second layer of protection.',
    descriptionAr: 'أمّن حساباتك بطبقة حماية ثانية.',
    category: LessonCategory.password,
    status: LessonStatus.notStarted,
    durationMinutes: 8,
    progressPercent: 0,
    iconAsset: 'assets/icons/password.png',
    difficulty: Difficulty.beginner,
    xpPoints: 70,
    tags: ['2FA', 'MFA', 'OTP', 'authenticator'],
    steps: [
      LessonStep(
        title: 'Why Passwords Alone Aren\'t Enough',
        content:
            'If an attacker obtains your password through a phishing attack, data breach, or keylogger — they own your account. 2FA adds a second required factor:\n\n• Something you know (password)\n• Something you have (phone, hardware key)\n\nEven with your password, attackers can\'t log in without your second factor.',
      ),
      LessonStep(
        title: '2FA Methods Ranked',
        content:
            'From weakest to strongest:\n\n1. SMS codes — convenient but vulnerable to SIM-swapping attacks\n2. Authenticator apps (Google Authenticator, Authy) — much stronger, codes never leave your device\n3. Hardware security keys (YubiKey) — phishing-resistant, strongest option\n\nEnable 2FA everywhere, but prefer authenticator apps over SMS when possible.',
      ),
      LessonStep(
        title: 'Best 2FA Method?',
        content: 'Which 2FA method is most resistant to phishing attacks?',
        isQuiz: true,
        options: [
          QuizOption('SMS one-time codes to your phone number'),
          QuizOption('Email verification codes'),
          QuizOption('Hardware security key (e.g. YubiKey)'),
          QuizOption('Security questions'),
        ],
        correctIndex: 2,
      ),
    ],
  ),

  LessonModel(
    id: 'mobile_security_201',
    titleEn: 'Mobile Device Security',
    titleAr: 'أمان الأجهزة المحمولة',
    descriptionEn: 'Harden your smartphone against physical and digital threats.',
    descriptionAr: 'تقوية هاتفك الذكي ضد التهديدات الجسدية والرقمية.',
    category: LessonCategory.privacy,
    status: LessonStatus.notStarted,
    durationMinutes: 11,
    progressPercent: 0,
    iconAsset: 'assets/icons/privacy.png',
    difficulty: Difficulty.intermediate,
    xpPoints: 85,
    tags: ['mobile', 'lock screen', 'encryption', 'updates'],
    steps: [
      LessonStep(
        title: 'Physical Security First',
        content:
            'Your phone is a gateway to everything. Physical security basics:\n\n• Use a strong PIN (6+ digits) or biometric + PIN\n• Enable auto-lock after 30 seconds\n• Never leave your phone unattended in public\n• Disable lock-screen notifications for sensitive apps\n• Enable "Find My Device" and remote wipe capability',
      ),
      LessonStep(
        title: 'Software Security',
        content:
            'Keeping software secure:\n\n• Install OS updates immediately — they contain critical security patches\n• Only install apps from official stores (Play Store, App Store)\n• Avoid sideloading APKs from unknown sources\n• Check developer reputation before installing any app\n• Uninstall apps you no longer use — they can still collect data in the background',
      ),
      LessonStep(
        title: 'Safe Behaviour',
        content: 'Your friend sends you a WhatsApp message: "Install this cool app" with a link to an APK file. What should you do?',
        isQuiz: true,
        options: [
          QuizOption('Install it — your friend sent it so it must be safe'),
          QuizOption('Don\'t install it — APKs from outside the Play Store are unsafe'),
          QuizOption('Install it but run an antivirus scan first'),
          QuizOption('Only install it if the APK is under 10MB'),
        ],
        correctIndex: 1,
      ),
    ],
  ),
];
