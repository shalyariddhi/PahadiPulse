import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../models/itinerary.dart';
import 'itinerary_day_detail_screen.dart';

class GeneratedItineraryScreen extends StatelessWidget {
  final GeneratedItinerary itinerary;

  const GeneratedItineraryScreen({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Your Optimized Eco Circuit'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Itinerary circuit exported to clipboard & saved in profile.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Circuit Badge
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF16261E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.forestAccent, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.forestAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${itinerary.daysCount} DAYS • ${itinerary.travellersCount} TRAVELLERS',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: ₹${itinerary.totalEstimatedCostINR.toInt()}',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    itinerary.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.forestAccent),
                      const SizedBox(width: 6),
                      Text(
                        'Regional Pressure Reduction: ${itinerary.pressureMitigationScore}%',
                        style: const TextStyle(color: AppColors.forestAccent, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    itinerary.rationale,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Day-by-Day Circuit Schedule',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            // Day Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itinerary.days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, idx) {
                final day = itinerary.days[idx];
                return _buildDayCard(context, day);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, ItineraryDay day) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItineraryDayDetailScreen(day: day)),
        );
      },
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forestGlow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.forestAccent),
                  ),
                  child: Text(
                    'DAY ${day.dayNumber}',
                    style: const TextStyle(color: AppColors.forestAccent, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    day.destinationName,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: day.pressureLevel == 'CRITICAL' ? AppColors.statusCritical.withOpacity(0.2) : AppColors.statusLow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: day.pressureLevel == 'CRITICAL' ? AppColors.statusCritical : AppColors.statusLow,
                    ),
                  ),
                  child: Text(
                    '${day.pressureScore.toInt()}% ${day.pressureLevel}',
                    style: TextStyle(
                      color: day.pressureLevel == 'CRITICAL' ? AppColors.statusCritical : AppColors.statusLow,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stay highlight
            Row(
              children: [
                const Icon(LucideIcons.home, size: 14, color: AppColors.pineTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Stay: ${day.stayRecommendation.name} (₹${day.stayRecommendation.costPerNightINR.toInt()}/night)',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Activities count
            Row(
              children: [
                const Icon(LucideIcons.compass, size: 14, color: AppColors.forestAccent),
                const SizedBox(width: 6),
                Text(
                  '${day.activities.length} Local Activities Included',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                const Row(
                  children: [
                    Text('View Schedule', style: TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                    SizedBox(width: 2),
                    Icon(LucideIcons.chevronRight, size: 12, color: AppColors.forestAccent),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
