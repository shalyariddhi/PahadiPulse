import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final notifs = appState.notifications;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Regional Alerts & Notices'),
      ),
      body: notifs.isEmpty
          ? const Center(child: Text('No notifications at this time', style: TextStyle(color: AppColors.textMuted)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final n = notifs[idx];
                final isRead = n['isRead'] as bool;
                final sev = n['severity'] as String;

                Color iconColor = AppColors.forestAccent;
                if (sev == 'CRITICAL') iconColor = AppColors.statusCritical;
                if (sev == 'MODERATE') iconColor = AppColors.statusModerate;

                return GestureDetector(
                  onTap: () => appState.markNotificationRead(n['id']),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? AppColors.forestCard : AppColors.forestGlow.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isRead ? AppColors.borderSubtle : AppColors.forestAccent),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          sev == 'CRITICAL' ? LucideIcons.alertTriangle : (sev == 'MODERATE' ? LucideIcons.cloudSnow : LucideIcons.bell),
                          color: iconColor,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      n['title'],
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(n['time'], style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['body'],
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
