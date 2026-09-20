import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isOffline) {
      return const SizedBox.shrink();
    }

    final draftCount = appState.reportDrafts.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.statusModerate.withValues(alpha: 0.18),
        border: Border(
          bottom: BorderSide(color: AppColors.statusModerate.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.statusModerate.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.wifiOff, size: 14, color: AppColors.statusModerate),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Low-Connectivity Mode',
                      style: TextStyle(
                        color: AppColors.statusModerate,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (appState.isSimulatedOffline) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.pineTeal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.pineTeal.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'DEMO SIMULATION',
                          style: TextStyle(color: AppColors.pineTeal, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  draftCount > 0
                      ? 'Viewing cached data • $draftCount draft${draftCount > 1 ? 's' : ''} saved locally'
                      : 'Viewing locally cached destinations and telemetry',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
              if (appState.isSimulatedOffline) {
                appState.toggleSimulatedOffline();
              } else {
                await appState.checkConnectivityAndSync();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    appState.isSimulatedOffline ? LucideIcons.toggleRight : LucideIcons.refreshCw,
                    size: 12,
                    color: AppColors.forestAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appState.isSimulatedOffline ? 'Go Online' : 'Retry',
                    style: const TextStyle(
                      color: AppColors.forestAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
}
