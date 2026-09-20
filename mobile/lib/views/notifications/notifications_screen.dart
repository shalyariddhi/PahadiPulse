import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../models/notification.dart';
import '../../providers/app_state.dart';
import '../destination/destination_detail_screen.dart';
import '../reports/report_detail_sheet.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifs = appState.notificationsList;
    final unreadCount = appState.unreadNotificationsCount;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        backgroundColor: AppColors.forestDark,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Alerts & Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusCritical,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                context.read<AppState>().markAllNotificationsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All alerts marked as read'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(LucideIcons.checkCheck, size: 16, color: AppColors.forestAccent),
              label: const Text(
                'Mark Read',
                style: TextStyle(color: AppColors.forestAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18, color: AppColors.textSecondary),
            onPressed: () => context.read<AppState>().fetchNotifications(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.forestAccent,
          labelColor: AppColors.forestAccent,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            const Tab(text: 'All'),
            Tab(text: unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread'),
            const Tab(text: 'Pressure'),
            const Tab(text: 'Trips & Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(notifs, appState),
          _buildNotificationList(notifs.where((n) => !n.read).toList(), appState, emptyMessage: 'All caught up! No unread notifications.'),
          _buildNotificationList(notifs.where((n) => n.type == 'HIGH_PRESSURE_ALERT' || n.type == 'PRESSURE_SPIKE' || n.type == 'SAVED_DESTINATION_ALERT').toList(), appState, emptyMessage: 'No active carrying capacity alerts.'),
          _buildNotificationList(notifs.where((n) => n.type == 'ITINERARY_UPDATE' || n.type == 'GENERAL_ANNOUNCEMENT' || n.type == 'PREDICTION_WARNING').toList(), appState, emptyMessage: 'No itinerary updates or travel advisories.'),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationItem> items, 
    AppState appState, {
    String emptyMessage = 'No notifications found.',
  }) {
    if (appState.isLoadingNotifications) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.forestAccent),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.forestCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(LucideIcons.bellOff, size: 28, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.forestAccent,
      backgroundColor: AppColors.forestCard,
      onRefresh: () => appState.fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildNotificationCard(context, item, appState);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item, AppState appState) {
    final meta = _getTypeMetadata(item.type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.read ? AppColors.borderSubtle : meta.color.withValues(alpha: 0.5),
          width: item.read ? 1 : 1.5,
        ),
        boxShadow: item.read
            ? null
            : [
                BoxShadow(
                  color: meta.color.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!item.read) {
              appState.markNotificationRead(item.id);
            }
            _handleNotificationDeepLink(context, item, appState);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: meta.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(meta.icon, size: 20, color: meta.color),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: meta.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        meta.label,
                                        style: TextStyle(
                                          color: meta.color,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatRelativeTime(item.createdAt),
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: item.read ? FontWeight.w600 : FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: TextStyle(
                          color: item.read ? AppColors.textMuted : AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                      if (item.relatedEntityId != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _getDeepLinkActionText(item),
                              style: TextStyle(
                                color: meta.color,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(LucideIcons.chevronRight, size: 12, color: meta.color),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationDeepLink(BuildContext context, NotificationItem item, AppState appState) {
    if (item.relatedEntityId == null || item.relatedEntityId!.isEmpty) return;

    final entityId = item.relatedEntityId!;
    
    // Check if it's a destination
    final matchedDest = appState.destinations.where((d) => d.id == entityId).firstOrNull;
    if (matchedDest != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(destination: matchedDest),
        ),
      );
      return;
    }

    // Check if it's a report
    final matchedReport = appState.allReports.where((r) => r.id == entityId).firstOrNull;
    if (matchedReport != null) {
      ReportDetailSheet.show(context, matchedReport);
      return;
    }
  }

  String _getDeepLinkActionText(NotificationItem item) {
    if (item.type == 'HIGH_PRESSURE_ALERT' || item.type == 'SAVED_DESTINATION_ALERT' || item.type == 'PRESSURE_SPIKE') {
      return 'View Capacity Telemetry';
    } else if (item.type == 'ITINERARY_UPDATE') {
      return 'View Eco-Smart Route';
    } else if (item.type == 'CRITICAL_REPORT' || item.type == 'HIGH_SEVERITY_ISSUE') {
      return 'Inspect Report Details';
    }
    return 'View Details';
  }

  _NotifMeta _getTypeMetadata(String type) {
    switch (type) {
      case 'HIGH_PRESSURE_ALERT':
      case 'PRESSURE_SPIKE':
        return _NotifMeta(
          icon: LucideIcons.flame,
          color: AppColors.statusModerate,
          label: 'PRESSURE SURGE',
        );
      case 'ITINERARY_UPDATE':
        return _NotifMeta(
          icon: LucideIcons.compass,
          color: AppColors.pineTeal,
          label: 'ROUTE UPDATE',
        );
      case 'SAVED_DESTINATION_ALERT':
        return _NotifMeta(
          icon: LucideIcons.bookmark,
          color: AppColors.forestAccent,
          label: 'SAVED DESTINATION',
        );
      case 'CRITICAL_REPORT':
        return _NotifMeta(
          icon: LucideIcons.alertOctagon,
          color: AppColors.statusCritical,
          label: 'CRITICAL HAZARD',
        );
      case 'PREDICTION_WARNING':
        return _NotifMeta(
          icon: LucideIcons.sparkles,
          color: Colors.purpleAccent,
          label: 'ML FORECAST',
        );
      default:
        return _NotifMeta(
          icon: LucideIcons.info,
          color: Colors.lightBlueAccent,
          label: 'TRAVEL ADVISORY',
        );
    }
  }

  String _formatRelativeTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Recent';
    }
  }
}

class _NotifMeta {
  final IconData icon;
  final Color color;
  final String label;

  _NotifMeta({
    required this.icon,
    required this.color,
    required this.label,
  });
}
