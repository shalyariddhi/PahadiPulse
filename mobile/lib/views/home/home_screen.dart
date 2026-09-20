import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/destination.dart';
import '../destination/destination_detail_screen.dart';
import '../planner/trip_planner_screen.dart';
import '../map/map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../saved/saved_destinations_screen.dart';
import '../experiences/experiences_screen.dart';
import '../experiences/provider_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final regional = appState.regionalPressure;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.forestGlow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.forestAccent, width: 1.5),
              ),
              child: const Icon(LucideIcons.mountain, color: AppColors.forestAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PAHADIPULSE',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user != null ? 'Hello, ${user.displayName}' : 'Uttarakhand Regional Intelligence',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.mapPin, color: AppColors.pineTeal),
            tooltip: 'Live Map',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(LucideIcons.bookmark, color: AppColors.textPrimary),
                if (appState.savedDestinationIds.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.forestAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${appState.savedDestinationIds.length}',
                        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedDestinationsScreen()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(LucideIcons.bell, color: AppColors.textPrimary),
                if (appState.unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.roseAlert,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${appState.unreadNotificationsCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  )
              ],
            ),
            tooltip: 'Alerts',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.forestAccent,
        backgroundColor: AppColors.forestCard,
        onRefresh: () async {
          await appState.fetchDestinations();
          await appState.fetchRegionalPressure();
          await appState.fetchProviders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PRIMARY HERO: PLAN MY TRIP
              _buildPlanTripHero(context),
              const SizedBox(height: 24),

              // 2. REGIONAL PRESSURE INTELLIGENCE WIDGET
              _buildRegionalPressureWidget(context, regional),
              const SizedBox(height: 28),

              // 3. RECOMMENDED LOWER-PRESSURE DESTINATIONS
              _buildSectionHeader(
                context,
                title: 'Eco Recommendations',
                subtitle: 'Low-pressure, scenic destinations with peaceful travel',
                onSeeAll: () {
                  // Navigate to Explore
                },
              ),
              const SizedBox(height: 14),
              _buildHorizontalDestinationList(context, appState.lowerPressureDestinations, isLowPressure: true),
              const SizedBox(height: 28),

              // 4. POPULAR DESTINATIONS (WITH REAL-TIME STATUS)
              _buildSectionHeader(
                context,
                title: 'High-Demand Destinations',
                subtitle: 'Check live crowd & traffic pressure before traveling',
                onSeeAll: () {},
              ),
              const SizedBox(height: 14),
              _buildHorizontalDestinationList(context, appState.popularDestinations, isLowPressure: false),
              const SizedBox(height: 28),

              // 5. LOCAL EXPERIENCES & HOMESTAYS
              _buildSectionHeader(
                context,
                title: 'Local Village Experiences',
                subtitle: 'Certified Garhwali & Kumaoni homestays and guides',
                onSeeAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExperiencesScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildExperiencesPreview(context, appState),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTripHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF0F1914)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.forestAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestAccent.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forestAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.sparkles, color: Colors.black, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'AI TRIP PLANNER',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Zero Crowds • 100% Local',
                  style: TextStyle(color: AppColors.pineTeal, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Avoid Over-Tourism.\nExplore Hidden Uttarakhand.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate personalized multi-day circuits that optimize budget, bypass traffic choke points, and support village homestays.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.sparkles, size: 18, color: Colors.black),
                label: const Text(
                  'PLAN MY TRIP NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalPressureWidget(BuildContext context, Map<String, dynamic>? regional) {
    final avgScore = (regional?['averageScore'] as num?)?.toDouble() ?? 32.9;
    final status = regional?['overallStatus'] ?? 'MODERATE';
    final dist = regional?['statusDistribution'] as Map<String, dynamic>? ?? {'LOW': 14, 'MODERATE': 4, 'HIGH': 0, 'CRITICAL': 3};

    Color statusColor;
    if (status == 'CRITICAL') {
      statusColor = AppColors.statusCritical;
    } else if (status == 'HIGH') {
      statusColor = AppColors.statusHigh;
    } else if (status == 'MODERATE') {
      statusColor = AppColors.statusModerate;
    } else {
      statusColor = AppColors.statusLow;
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
              const Icon(LucideIcons.gauge, color: AppColors.forestAccent, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Regional Pressure Telemetry',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'State Avg: $avgScore/100',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '🟢 ${dist['LOW'] ?? 14} Low  🟡 ${dist['MODERATE'] ?? 4} Mod  🔴 ${dist['CRITICAL'] ?? 3} High',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: avgScore / 100.0,
              minHeight: 8,
              backgroundColor: AppColors.forestDark,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: const Row(
                children: [
                  Text('See all', style: TextStyle(color: AppColors.forestAccent, fontSize: 13, fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 14, color: AppColors.forestAccent),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildHorizontalDestinationList(BuildContext context, List<Destination> destinations, {required bool isLowPressure}) {
    if (destinations.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: const Text('Loading regional destinations...', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, idx) {
          final d = destinations[idx];
          return _buildDestinationCard(context, d);
        },
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, Destination d) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.forestCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    d.imageUrl,
                    height: 125,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 125,
                      color: AppColors.forestGlow,
                      child: const Center(child: Icon(LucideIcons.mountain, color: AppColors.forestAccent)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: d.statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${d.pressureScore.toInt()}% ${d.status}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          d.district,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${d.avgDailyBudgetINR.toInt()}/day',
                        style: const TextStyle(
                          color: AppColors.forestAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${d.altitudeMeters}m',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencesPreview(BuildContext context, AppState state) {
    final provs = state.providers.take(3).toList();
    if (provs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.forestCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Center(
          child: Text('Loading verified local experiences...', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    IconData _providerIcon(String cat) {
      switch (cat.toUpperCase()) {
        case 'HOMESTAY': return LucideIcons.home;
        case 'LOCAL_GUIDE': return LucideIcons.compass;
        case 'LOCAL_FOOD': return LucideIcons.utensils;
        case 'HANDICRAFTS': return LucideIcons.scissors;
        case 'LOCAL_PRODUCTS': return LucideIcons.shoppingBag;
        case 'CULTURAL_EXPERIENCE': return LucideIcons.music;
        case 'RENTAL': return LucideIcons.bike;
        default: return LucideIcons.sparkles;
      }
    }

    return Column(
      children: provs.map((p) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProviderDetailScreen(provider: p),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.forestCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forestGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _providerIcon(p.category),
                    color: AppColors.forestAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (p.isCertified)
                            const Icon(LucideIcons.checkCircle, color: AppColors.forestAccent, size: 14),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.destinationName} • ${p.categoryLabel} • ₹${p.priceStartingINR.toInt()}',
                        style: const TextStyle(color: AppColors.pineTeal, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
