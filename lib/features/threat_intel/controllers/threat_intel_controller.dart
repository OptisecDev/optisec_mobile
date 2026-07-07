import 'package:get/get.dart';

import '../../../core/services/threat_intel_service.dart';
import '../../../shared/models/threat_alert_model.dart';

class ThreatIntelController extends GetxController {
  final alerts = <ThreatAlert>[].obs;
  final isLoading = false.obs;
  final Rxn<DateTime> lastUpdated = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  Future<void> refresh({bool forceRefresh = false}) async {
    isLoading.value = true;
    final result = await ThreatIntelService.instance
        .fetchAlerts(forceRefresh: forceRefresh);
    alerts.value = _sortedBySeverityThenRecency(result);
    lastUpdated.value = ThreatIntelService.instance.updatedAt;
    isLoading.value = false;
  }

  List<ThreatAlert> _sortedBySeverityThenRecency(List<ThreatAlert> input) {
    final sorted = List<ThreatAlert>.from(input);
    sorted.sort((a, b) {
      final severityDiff = b.severity.index.compareTo(a.severity.index);
      if (severityDiff != 0) return severityDiff;
      return b.publishedAt.compareTo(a.publishedAt);
    });
    return sorted;
  }

  ThreatAlert? get topAlert => alerts.isEmpty ? null : alerts.first;
}
