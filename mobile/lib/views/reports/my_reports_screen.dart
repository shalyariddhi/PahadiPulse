import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/report.dart';
import 'report_issue_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final reports = appState.myReports;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Community Reports'),
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
      body: RefreshIndicator(
        color: AppColors.forestAccent,
        backgroundColor: AppColors.forestCard,
        onRefresh: () async {
          await appState.fetchMyReports();
        },
        child: reports.isEmpty
            ? Center(
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
                        'No Reports Submitted',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Help keep Uttarakhand pristine. Report water deficits, traffic jams, or unmanaged waste.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Submit a Report'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, idx) {
                  final rep = reports[idx];
                  return _buildReportCard(context, rep);
                },
              ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report rep) {
    Color statusColor;
    if (rep.status == 'RESOLVED') {
      statusColor = AppColors.statusLow;
    } else if (rep.status == 'IN_PROGRESS') {
      statusColor = AppColors.statusModerate;
    } else {
      statusColor = AppColors.pineTeal;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.forestGlow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rep.category.toUpperCase(),
                  style: const TextStyle(color: AppColors.forestAccent, fontWeight: FontWeight.w800, fontSize: 10),
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
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  rep.status.replaceAll('_', ' '),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rep.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),

          // AI Triage Badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.forestDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.sparkles, size: 14, color: AppColors.forestAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Severity ${rep.aiSeverity}/5 • ${rep.aiExplanation}',
                    style: const TextStyle(color: AppColors.pineTeal, fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
