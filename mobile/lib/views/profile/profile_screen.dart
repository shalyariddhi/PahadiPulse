import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../saved/saved_destinations_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Traveler Profile'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.forestGlow,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.forestAccent, width: 2),
                    ),
                    child: const Icon(LucideIcons.user, size: 40, color: AppColors.forestAccent),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.displayName ?? 'Pahadi Traveler',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'traveler@pahadipulse.in',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.forestAccent),
                    ),
                    child: Text(
                      '${(user?.role ?? 'TOURIST').toUpperCase()} MEMBER',
                      style: const TextStyle(color: AppColors.forestAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Eco Impact & Stats
            Row(
              children: [
                Expanded(child: _buildStatCard('Trips Planned', '${appState.currentItinerary != null ? 1 : 0}', LucideIcons.compass)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Saved Spots', '${appState.savedDestinationIds.length}', LucideIcons.bookmark)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Reports Filed', '${appState.myReports.length}', LucideIcons.alertTriangle)),
              ],
            ),
            const SizedBox(height: 24),

            // Settings & Quick Links
            _buildActionTile(
              icon: LucideIcons.bookmark,
              title: 'Saved Destinations',
              subtitle: '${appState.savedDestinationIds.length} bookmarks saved',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedDestinationsScreen()),
                );
              },
            ),
            _buildActionTile(
              icon: LucideIcons.sliders,
              title: 'App Settings & API Server',
              subtitle: 'Configure local IP, developer mode, and theme',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _buildActionTile(
              icon: LucideIcons.helpCircle,
              title: 'About PahadiPulse & Hackathon',
              subtitle: 'IBM Hackathon PS-04 • Solve for My Region',
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            _buildActionTile(
              icon: LucideIcons.logOut,
              title: 'Log Out',
              subtitle: 'Sign out of current mobile session',
              isDestructive: true,
              onTap: () {
                appState.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.forestAccent),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? AppColors.statusCritical : AppColors.forestAccent),
        title: Text(title, style: TextStyle(color: isDestructive ? AppColors.statusCritical : AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.forestCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.forestAccent)),
        title: const Row(
          children: [
            Icon(LucideIcons.mountain, color: AppColors.forestAccent),
            SizedBox(width: 8),
            Text('PahadiPulse', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const Text(
          'PahadiPulse is an AI-powered Regional Tourism & Community Intelligence platform built for IBM Hackathon PS-04 ("Solve for My Region") to solve tourism pressure, water stress, and livelihood distribution across Uttarakhand.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.forestAccent)),
          ),
        ],
      ),
    );
  }
}
