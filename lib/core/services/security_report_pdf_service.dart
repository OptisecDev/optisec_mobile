import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/cyber_academy/controllers/cyber_academy_controller.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/subscription/controllers/subscription_controller.dart';
import '../../shared/models/security_score_model.dart';

/// Builds a "Security Report" PDF from the app's live, already-computed
/// data (DashboardController's [SecurityScoreModel] plus Cyber Academy
/// progress) and hands it to the OS share sheet. Pro-gating happens at the
/// call site (see SettingsController.exportSecurityReport) -- this class
/// only renders and shares, it never checks entitlement itself.
class SecurityReportPdfService {
  SecurityReportPdfService._();

  static Future<void> generateAndShare() async {
    final score = Get.find<DashboardController>().score.value;
    final academy = Get.find<CyberAcademyController>();
    final licenseeLabel =
        Get.find<SubscriptionController>().subscription.value.licenseeLabel;

    final bytes = await _buildDocument(
      score: score,
      completedLessons: academy.completedCount,
      totalLessons: academy.totalCount,
      userLevel: academy.userLevel.value,
      userXp: academy.userXp.value,
      licenseeLabel: licenseeLabel,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'optisec-security-report-${_dateStamp(score.lastScan)}.pdf',
    );
  }

  static String _dateStamp(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  static Future<Uint8List> _buildDocument({
    required SecurityScoreModel score,
    required int completedLessons,
    required int totalLessons,
    required int userLevel,
    required int userXp,
    String? licenseeLabel,
  }) {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _header(score.lastScan),
        footer: (context) => _footer(context, licenseeLabel),
        build: (context) => [
          _scoreSummary(score),
          pw.SizedBox(height: 20),
          _breakdownTable(score),
          pw.SizedBox(height: 20),
          _threatsSection(score),
          pw.SizedBox(height: 20),
          _academySection(completedLessons, totalLessons, userLevel, userXp),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(DateTime lastScan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'OptiSec Security Report',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              _formatDate(lastScan),
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _footer(pw.Context context, String? licenseeLabel) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              licenseeLabel != null
                  ? 'OptiSec Pro — licensed to $licenseeLabel'
                  : 'OptiSec Pro',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _scoreSummary(SecurityScoreModel score) {
    final color = _scoreColor(score.overall);
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Overall Security Score',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text(score.statusLabel,
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
            ],
          ),
          pw.Text(
            '${score.overall}',
            style: pw.TextStyle(
                fontSize: 36, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  static pw.Widget _breakdownTable(SecurityScoreModel score) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Score Breakdown'),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
          },
          children: [
            _row('WiFi Shield', '${score.wifiScore}'),
            _row('Privacy Guard', '${score.privacyScore}'),
            _row('App Lock', '${score.appScore}'),
            _row('Networks Scanned (Last Scan)', '${score.networksScanned}'),
            _row('Threats Detected', '${score.threatsDetected}'),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _row(String label, String value) {
    const style = pw.TextStyle(fontSize: 10);
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(label, style: style),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(value, style: style),
      ),
    ]);
  }

  static pw.Widget _threatsSection(SecurityScoreModel score) {
    if (score.threats.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Threats'),
          pw.SizedBox(height: 8),
          pw.Text('No active threats detected.',
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Threats (${score.threats.length})'),
        pw.SizedBox(height: 8),
        ...score.threats.map((t) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: _severityColor(t.severity),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          t.severity.name.toUpperCase(),
                          style: const pw.TextStyle(
                              fontSize: 7, color: PdfColors.white),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(t.title,
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(t.description,
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            )),
      ],
    );
  }

  static pw.Widget _academySection(
      int completed, int total, int level, int xp) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Cyber Academy Progress'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Level $level — $xp XP — $completed of $total lessons completed',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      );

  static PdfColor _scoreColor(int overall) {
    switch (scoreTierFor(overall)) {
      case ScoreTier.safe:
        return PdfColors.green700;
      case ScoreTier.good:
        return PdfColors.blue700;
      case ScoreTier.warning:
        return PdfColors.orange700;
      case ScoreTier.critical:
        return PdfColors.red700;
    }
  }

  static PdfColor _severityColor(ThreatSeverity s) {
    switch (s) {
      case ThreatSeverity.critical:
        return PdfColors.red800;
      case ThreatSeverity.high:
        return PdfColors.red600;
      case ThreatSeverity.medium:
        return PdfColors.orange600;
      case ThreatSeverity.low:
        return PdfColors.blueGrey400;
    }
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
