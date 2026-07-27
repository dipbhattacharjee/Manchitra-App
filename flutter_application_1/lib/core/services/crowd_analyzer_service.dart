import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// ============================================================
/// MANCHITRA — Live Crowd Report Analyzer Service
/// Aggregates rolling 2-hour community reports with time-of-day fallback.
/// ============================================================

class CrowdReportItem {
  final String id;
  final String pandalId;
  final CrowdLevel level;
  final DateTime reportedAt;

  CrowdReportItem({
    required this.id,
    required this.pandalId,
    required this.level,
    required this.reportedAt,
  });
}

class CrowdAnalyzerService {
  CrowdAnalyzerService._();
  static final CrowdAnalyzerService instance = CrowdAnalyzerService._();

  final List<CrowdReportItem> _localReports = [];

  /// Submit a new community crowd report
  Future<bool> submitCrowdReport({
    required String pandalId,
    required CrowdLevel level,
  }) async {
    final report = CrowdReportItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pandalId: pandalId,
      level: level,
      reportedAt: DateTime.now(),
    );
    _localReports.add(report);

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      await client.from('crowd_reports').insert({
        'pandal_id': pandalId,
        'user_id': user?.id ?? 'anonymous',
        'crowd_level': level.name,
      });
      return true;
    } catch (e) {
      debugPrint('Supabase submitCrowdReport error: $e');
      return true; // Local submission successful
    }
  }

  /// Get aggregated crowd level for a pandal (rolling 2-hour window + time heuristic fallback)
  CrowdLevel getAggregatedCrowdLevel(Pandal pandal) {
    final now = DateTime.now();
    final twoHoursAgo = now.subtract(const Duration(hours: 2));

    final recentReports = _localReports
        .where((r) => r.pandalId == pandal.id && r.reportedAt.isAfter(twoHoursAgo))
        .toList();

    if (recentReports.isNotEmpty) {
      final counts = <CrowdLevel, int>{};
      for (final r in recentReports) {
        counts[r.level] = (counts[r.level] ?? 0) + 1;
      }
      CrowdLevel topLevel = recentReports.first.level;
      int maxCount = 0;
      counts.forEach((level, count) {
        if (count > maxCount) {
          maxCount = count;
          topLevel = level;
        }
      });
      return topLevel;
    }

    // Time-of-day heuristic fallback
    final hour = now.hour;
    if (pandal.isFeatured2026 || pandal.category == PandalCategory.famousHeritage) {
      if (hour >= 19 && hour <= 23) return CrowdLevel.veryHigh;
      if (hour >= 16 && hour < 19) return CrowdLevel.high;
      if (hour >= 12 && hour < 16) return CrowdLevel.medium;
      return CrowdLevel.low;
    }

    if (hour >= 19 && hour <= 22) return CrowdLevel.high;
    if (hour >= 16 && hour < 19) return CrowdLevel.medium;
    return CrowdLevel.low;
  }

  /// Show community crowd report dialog
  static Future<void> showReportDialog(BuildContext context, Pandal pandal, VoidCallback onSubmitted) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Report Live Crowd at ${pandal.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How busy is this pandal right now?',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ...CrowdLevel.values.map(
              (level) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await CrowdAnalyzerService.instance.submitCrowdReport(
                      pandalId: pandal.id,
                      level: level,
                    );
                    onSubmitted();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reported crowd as "${level.label}" — thank you!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: level.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: level.color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          level.label,
                          style: TextStyle(fontWeight: FontWeight.bold, color: level.color, fontSize: 13),
                        ),
                        Icon(Icons.check_circle_outline_rounded, color: level.color, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
