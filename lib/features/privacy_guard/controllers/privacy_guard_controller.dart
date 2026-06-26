import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum PrivacyFilterMode { all, granted, high, medium }

enum PrivacySortMode { risk, name, appCount }

class PermissionInfo {
  final String id;
  final String nameEn;
  final String nameAr;
  final IconData icon;
  final bool isGranted;
  final int appsCount;
  final String risk; // 'low' | 'medium' | 'high'
  final String descriptionEn;
  final String recommendationEn;
  final List<String> appNames;

  const PermissionInfo({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
    required this.isGranted,
    required this.appsCount,
    required this.risk,
    required this.descriptionEn,
    required this.recommendationEn,
    this.appNames = const [],
  });

  Color riskColor(BuildContext context) {
    switch (risk) {
      case 'high':
        return const Color(0xFFFF4757);
      case 'medium':
        return const Color(0xFFFFB020);
      default:
        return const Color(0xFF00D4AA);
    }
  }

  String get riskLabel {
    switch (risk) {
      case 'high':
        return 'High Risk';
      case 'medium':
        return 'Medium Risk';
      default:
        return 'Low Risk';
    }
  }
}

class PrivacyGuardController extends GetxController {
  final privacyScore = 0.obs;
  final isLoading = false.obs;
  final isScanning = false.obs;
  final permissions = <PermissionInfo>[].obs;
  final filterMode = PrivacyFilterMode.all.obs;
  final sortMode = PrivacySortMode.risk.obs;

  // 7-day privacy score history
  final scoreHistory = <double>[72, 68, 75, 70, 80, 78, 0].obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    isLoading.value = true;

    List<PermissionStatus> statuses;
    try {
      statuses = await Future.wait([
        Permission.location.status,
        Permission.camera.status,
        Permission.microphone.status,
        Permission.contacts.status,
        Permission.phone.status,
        Permission.storage.status,
      ]).timeout(const Duration(seconds: 2));
    } catch (_) {
      // Timeout or platform error — fall back to dummy denied statuses so the
      // UI doesn't stay on the loading spinner forever.
      statuses = List.filled(6, PermissionStatus.denied);
    }

    permissions.value = [
      PermissionInfo(
        id: 'location',
        nameEn: 'Location',
        nameAr: 'الموقع',
        icon: Icons.location_on_rounded,
        isGranted: statuses[0].isGranted,
        appsCount: 3,
        risk: statuses[0].isGranted ? 'medium' : 'low',
        descriptionEn:
            'Allows apps to access your precise GPS location. Commonly used by maps, weather, and delivery apps.',
        recommendationEn:
            'Change to "Only while using" and disable for apps that don\'t need navigation.',
        appNames: ['Google Maps', 'Weather App', 'Food Delivery'],
      ),
      PermissionInfo(
        id: 'camera',
        nameEn: 'Camera',
        nameAr: 'الكاميرا',
        icon: Icons.camera_alt_rounded,
        isGranted: statuses[1].isGranted,
        appsCount: 2,
        risk: statuses[1].isGranted ? 'medium' : 'low',
        descriptionEn:
            'Grants access to take photos and record video. Misused by spyware to capture images silently.',
        recommendationEn:
            'Only grant camera access to apps that genuinely need it like camera or video call apps.',
        appNames: ['Instagram', 'Video Call App'],
      ),
      PermissionInfo(
        id: 'microphone',
        nameEn: 'Microphone',
        nameAr: 'الميكروفون',
        icon: Icons.mic_rounded,
        isGranted: statuses[2].isGranted,
        appsCount: 4,
        risk: statuses[2].isGranted ? 'high' : 'low',
        descriptionEn:
            'One of the highest-risk permissions. Apps with mic access can record conversations without obvious indication.',
        recommendationEn:
            'Revoke microphone from all apps except voice calls and voice assistants.',
        appNames: ['Social Media App', 'Music App', 'Voice Recorder', 'Podcast App'],
      ),
      PermissionInfo(
        id: 'contacts',
        nameEn: 'Contacts',
        nameAr: 'جهات الاتصال',
        icon: Icons.contacts_rounded,
        isGranted: statuses[3].isGranted,
        appsCount: 5,
        risk: statuses[3].isGranted ? 'high' : 'low',
        descriptionEn:
            'Exposes the full contact list including names, phone numbers, and email addresses of everyone you know.',
        recommendationEn:
            'Only messaging and dialer apps need contacts. Revoke from all social and utility apps.',
        appNames: ['WhatsApp', 'Telegram', 'Email Client', 'Calendar App', 'Backup App'],
      ),
      PermissionInfo(
        id: 'phone',
        nameEn: 'Phone',
        nameAr: 'الهاتف',
        icon: Icons.phone_rounded,
        isGranted: statuses[4].isGranted,
        appsCount: 1,
        risk: statuses[4].isGranted ? 'high' : 'low',
        descriptionEn:
            'Allows apps to read your phone number, IMEI, and call history. Can be used for device fingerprinting.',
        recommendationEn:
            'Only grant to your primary dialer app. Revoke from all other applications immediately.',
        appNames: ['Phone App'],
      ),
      PermissionInfo(
        id: 'storage',
        nameEn: 'Storage',
        nameAr: 'التخزين',
        icon: Icons.folder_rounded,
        isGranted: statuses[5].isGranted,
        appsCount: 6,
        risk: statuses[5].isGranted ? 'medium' : 'low',
        descriptionEn:
            'Grants read/write access to your files, photos, and documents. Can expose sensitive files to third parties.',
        recommendationEn:
            'Use the file picker instead of granting broad storage access. Review which apps really need it.',
        appNames: ['Gallery', 'File Manager', 'Photo Editor', 'Backup', 'Browser', 'PDF Reader'],
      ),
    ];

    _calculateScore();
    scoreHistory[6] = privacyScore.value.toDouble();
    isLoading.value = false;
  }

  Future<void> runScan() async {
    isScanning.value = true;
    await checkPermissions();
    isScanning.value = false;
    Get.snackbar(
      'Privacy Scan Complete',
      'Found $highRiskCount high-risk and $mediumRiskCount medium-risk permissions.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _calculateScore() {
    final granted = permissions.where((p) => p.isGranted).length;
    final highRisk = highRiskCount;
    final mediumRisk = mediumRiskCount;
    final base = 100 - (highRisk * 15) - (mediumRisk * 8) - (granted * 2);
    privacyScore.value = base.clamp(0, 100);
  }

  void setFilter(PrivacyFilterMode mode) => filterMode.value = mode;
  void setSort(PrivacySortMode mode) => sortMode.value = mode;

  List<PermissionInfo> get filteredPermissions {
    var list = List<PermissionInfo>.from(permissions);
    switch (filterMode.value) {
      case PrivacyFilterMode.granted:
        list = list.where((p) => p.isGranted).toList();
        break;
      case PrivacyFilterMode.high:
        list = list.where((p) => p.risk == 'high').toList();
        break;
      case PrivacyFilterMode.medium:
        list = list.where((p) => p.risk == 'medium').toList();
        break;
      case PrivacyFilterMode.all:
        break;
    }
    switch (sortMode.value) {
      case PrivacySortMode.risk:
        const order = {'high': 0, 'medium': 1, 'low': 2};
        list.sort((a, b) => (order[a.risk] ?? 2).compareTo(order[b.risk] ?? 2));
        break;
      case PrivacySortMode.name:
        list.sort((a, b) => a.nameEn.compareTo(b.nameEn));
        break;
      case PrivacySortMode.appCount:
        list.sort((a, b) => b.appsCount.compareTo(a.appsCount));
        break;
    }
    return list;
  }

  Future<void> revokePermission(PermissionInfo perm) async {
    await openAppSettings();
  }

  int get highRiskCount =>
      permissions.where((p) => p.isGranted && p.risk == 'high').length;
  int get mediumRiskCount =>
      permissions.where((p) => p.isGranted && p.risk == 'medium').length;
  int get grantedCount => permissions.where((p) => p.isGranted).length;
  int get deniedCount => permissions.where((p) => !p.isGranted).length;
}
