import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../models/report.dart';

class ReportDetailSheet extends StatelessWidget {
  final Report report;

  const ReportDetailSheet({super.key, required this.report});

  static void show(BuildContext context, Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportDetailSheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stages = [
      {"label": "Submitted", "sub": "Citizen logged"},
      {"label": "AI Classified", "sub": "Severity assessed"},
      {"label": "Verified", "sub": "Nodal review"},
      {"label": "Assigned", "sub": "Dept dispatch"},
      {"label": "Resolved", "sub": "Action completed"},
    ];

    final currentStage = report.workflowStageIndex;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.forestDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: report.categoryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(report.categoryIcon, color: report.categoryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            report.id,
                            style: const TextStyle(
                              color: AppColors.forestAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: report.statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: report.statusColor, width: 0.8),
                            ),
                            child: Text(
                              report.statusDisplayLabel.toUpperCase(),
                              style: TextStyle(
                                color: report.statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${report.category} • ${report.destinationName}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.borderSubtle, height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Five-stage Workflow Visualizer
                  const Text(
                    'RESOLUTION WORKFLOW',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.forestCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(stages.length, (i) {
                        final isPassed = i <= currentStage;
                        final isCurrent = i == currentStage;
                        return Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPassed
                                      ? (isCurrent ? AppColors.forestAccent : AppColors.pineTeal)
                                      : AppColors.forestDark,
                                  border: Border.all(
                                    color: isPassed ? Colors.transparent : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Center(
                                  child: isPassed
                                      ? Icon(
                                          i < currentStage ? LucideIcons.check : LucideIcons.loader,
                                          size: 13,
                                          color: isCurrent ? Colors.black : Colors.white,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stages[i]["label"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isPassed ? AppColors.textPrimary : AppColors.textMuted,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. AI Intelligence Assessment Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.forestGlow,
                          AppColors.forestCard,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.forestAccent.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.sparkles, color: AppColors.forestAccent, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'AI Triage & Classification',
                              style: TextStyle(
                                color: AppColors.forestAccent,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(report.aiSeverity).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getSeverityColor(report.aiSeverity)),
                              ),
                              child: Text(
                                'Severity ${report.aiSeverity}/5',
                                style: TextStyle(
                                  color: _getSeverityColor(report.aiSeverity),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          report.aiExplanation,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.forestDark.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              report.adminNotes!,
                              style: const TextStyle(
                                color: AppColors.pineTeal,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Issue Description
                  const Text(
                    'ISSUE DESCRIPTION',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.forestCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      report.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Photo Attachment (if present)
                  if (report.imageUrl.isNotEmpty) ...[
                    const Text(
                      'PHOTO EVIDENCE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: AppColors.forestCard,
                        child: CachedNetworkImage(
                          imageUrl: report.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(color: AppColors.forestAccent),
                          ),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(LucideIcons.image, color: AppColors.textMuted, size: 36),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 5. Geolocation & Metadata
                  const Text(
                    'LOCATION & GEOTAG',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.forestCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, color: AppColors.pineTeal, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${report.latitude.toStringAsFixed(4)}° N, ${report.longitude.toStringAsFixed(4)}° E',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.clock, color: AppColors.textMuted, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'Reported: ${report.createdAt.substring(0, 10)} ${report.createdAt.length > 16 ? report.createdAt.substring(11, 16) : ""}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int sev) {
    if (sev >= 5) return AppColors.statusCritical;
    if (sev >= 4) return AppColors.statusHigh;
    if (sev >= 3) return AppColors.statusModerate;
    return AppColors.statusLow;
  }
}
