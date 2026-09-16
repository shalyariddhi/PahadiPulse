import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../models/itinerary.dart';

class ItineraryDayDetailScreen extends StatelessWidget {
  final ItineraryDay day;

  const ItineraryDayDetailScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: Text('Day ${day.dayNumber}: ${day.destinationName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.forestGlow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.mountain, color: AppColors.forestAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.destinationName,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${day.district} • Pressure: ${day.pressureScore.toInt()}% (${day.pressureLevel})',
                          style: const TextStyle(color: AppColors.pineTeal, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stay Recommendation Box
            const Text('Accommodation & Homestay', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.pineTeal.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.home, color: AppColors.forestAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          day.stayRecommendation.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                      Text(
                        '₹${day.stayRecommendation.costPerNightINR.toInt()}/night',
                        style: const TextStyle(color: AppColors.forestAccent, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    day.stayRecommendation.type,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (day.stayRecommendation.bookingContact != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(LucideIcons.phone, size: 13, color: AppColors.pineTeal),
                        const SizedBox(width: 6),
                        Text(
                          day.stayRecommendation.bookingContact!,
                          style: const TextStyle(color: AppColors.pineTeal, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Activities Timeline
            const Text('Hourly Activities & Experiences', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...day.activities.map((act) => _buildActivityTimelineTile(act)).toList(),
            const SizedBox(height: 20),

            // Transit Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.forestDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.compass, size: 16, color: AppColors.forestAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      day.travelNote,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimelineTile(ItineraryActivity act) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.forestDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              act.time,
              style: const TextStyle(color: AppColors.forestAccent, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  act.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.forestGlow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        act.category,
                        style: const TextStyle(color: AppColors.pineTeal, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '~₹${act.costEstimateINR.toInt()}',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
