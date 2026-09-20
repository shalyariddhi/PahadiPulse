import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/report.dart';
import 'report_issue_screen.dart';
import 'report_detail_sheet.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  String _selectedCategoryFilter = 'ALL';

  final List<String> _filterCategories = [
    'ALL',
    'ROAD',
    'WATER',
    'WASTE',
    'TRAFFIC',
    'HEALTH',
    'CONNECTIVITY',
    'TOURISM',
    'ENVIRONMENT',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allReports = appState.myReports;

    final filteredReports = _selectedCategoryFilter == 'ALL'
        ? allReports
        : allReports.where((r) => r.category.toUpperCase() == _selectedCategoryFilter || r.aiCategory.toUpperCase() == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Community Reports'),
        backgroundColor: AppColors.forestCard,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppColors.forestAccent),
            tooltip: 'Report Issue',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Carousel
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filterCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _filterCategories[idx];
                final isSel = _selectedCategoryFilter == cat;
                return ChoiceChip(
                  label: Text(cat == 'ALL' ? 'All Categories' : cat),
                  selected: isSel,
                  selectedColor: AppColors.forestAccent,
                  backgroundColor: AppColors.forestCard,
                  side: BorderSide(color: isSel ? AppColors.forestAccent : AppColors.borderSubtle),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategoryFilter = cat);
                  },
                );
              },
            ),
          ),

          const Divider(color: AppColors.borderSubtle, height: 1),

          // Offline Drafts Banner & Queue (if any)
          if (appState.reportDrafts.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.statusModerate.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.statusModerate.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.save, size: 16, color: AppColors.statusModerate),
                          const SizedBox(width: 8),
                          Text(
                            'Offline Drafts Queue (${appState.reportDrafts.length})',
                            style: const TextStyle(
                              color: AppColors.statusModerate,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (!appState.isOffline)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            backgroundColor: AppColors.forestAccent.withValues(alpha: 0.15),
                          ),
                          onPressed: appState.isSyncingDrafts
                              ? null
                              : () async {
                                  final synced = await appState.syncPendingReportDrafts();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Successfully submitted $synced draft report${synced > 1 ? 's' : ''}!'),
                                        backgroundColor: AppColors.forestAccent,
                                      ),
                                    );
                                  }
                                },
                          icon: appState.isSyncingDrafts
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestAccent))
                              : const Icon(LucideIcons.uploadCloud, size: 14, color: AppColors.forestAccent),
                          label: Text(
                            appState.isSyncingDrafts ? 'Syncing...' : 'Sync All',
                            style: const TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...appState.reportDrafts.map((draft) => Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.forestCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.statusModerate.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          draft.category,
                                          style: const TextStyle(color: AppColors.statusModerate, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        draft.destinationName.isNotEmpty ? draft.destinationName : draft.destinationId,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    draft.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusCritical),
                              tooltip: 'Delete Draft',
                              onPressed: () => appState.deleteReportDraft(draft.id),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],

          // Reports List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.forestAccent,
              backgroundColor: AppColors.forestCard,
              onRefresh: () async {
                await appState.fetchMyReports();
              },
              child: appState.isLoadingReports
                  ? const Center(child: CircularProgressIndicator(color: AppColors.forestAccent))
                  : filteredReports.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, idx) {
                            final rep = filteredReports[idx];
                            return _buildReportCard(context, rep);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.forestCard,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.checkCircle, size: 48, color: AppColors.forestAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Reports Found',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Help keep Uttarakhand pristine. Report water deficits, landslides, traffic gridlocks, or waste accumulation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Report New Issue', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report rep) {
    final stages = ["Submitted", "AI Classified", "Verified", "Assigned", "Resolved"];
    final currentStage = rep.workflowStageIndex;

    return InkWell(
      onTap: () => ReportDetailSheet.show(context, rep),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.forestCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Category Chip, Destination, Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rep.categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: rep.categoryColor, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rep.categoryIcon, size: 12, color: rep.categoryColor),
                      const SizedBox(width: 4),
                      Text(
                        rep.category.toUpperCase(),
                        style: TextStyle(color: rep.categoryColor, fontWeight: FontWeight.w900, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rep.destinationName,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rep.statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: rep.statusColor, width: 0.8),
                  ),
                  child: Text(
                    rep.statusDisplayLabel.toUpperCase(),
                    style: TextStyle(color: rep.statusColor, fontWeight: FontWeight.w800, fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              rep.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 5-Stage Stepper Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.forestDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(stages.length, (i) {
                  final isPassed = i <= currentStage;
                  final isCurrent = i == currentStage;
                  return Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPassed
                              ? (isCurrent ? AppColors.forestAccent : AppColors.pineTeal)
                              : Colors.white12,
                        ),
                        child: Center(
                          child: isPassed
                              ? Icon(LucideIcons.check, size: 8, color: isCurrent ? Colors.black : Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stages[i],
                        style: TextStyle(
                          color: isCurrent
                              ? AppColors.forestAccent
                              : (isPassed ? AppColors.textPrimary : AppColors.textMuted),
                          fontSize: 8.5,
                          fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      if (i < stages.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(LucideIcons.chevronRight, size: 8, color: Colors.white24),
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),

            // Bottom row: AI Severity & Geotag
            Row(
              children: [
                const Icon(LucideIcons.sparkles, size: 12, color: AppColors.forestAccent),
                const SizedBox(width: 4),
                Text(
                  'AI Severity: ${rep.aiSeverity}/5',
                  style: const TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${(rep.aiConfidence * 100).toInt()}% conf',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                if (rep.imageUrl.isNotEmpty) ...[
                  const Spacer(),
                  const Icon(LucideIcons.image, size: 12, color: AppColors.pineTeal),
                  const SizedBox(width: 4),
                  const Text('Photo attached', style: TextStyle(color: AppColors.pineTeal, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
