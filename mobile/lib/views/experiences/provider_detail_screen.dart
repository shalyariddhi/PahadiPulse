import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../models/provider.dart';

class ProviderDetailScreen extends StatelessWidget {
  final LocalProvider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final p = provider;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: Text(p.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.forestGlow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.forestAccent),
                        ),
                        child: Icon(
                          p.isHomestay ? LucideIcons.home : (p.isGuide ? LucideIcons.compass : LucideIcons.utensils),
                          color: AppColors.forestAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Host: ${p.ownerName}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(LucideIcons.star, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text('${p.rating} (${p.reviewCount} reviews)', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pricing', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          Text('₹${p.priceStartingINR.toInt()} / unit', style: const TextStyle(color: AppColors.forestAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Location', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          Text(p.destinationName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          Text(p.isCertified ? 'Verified' : 'Local', style: const TextStyle(color: AppColors.pineTeal, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text('About the Experience', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              p.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Certified Benefits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forestGlow.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.forestAccent.withOpacity(0.5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.checkCheck, color: AppColors.forestAccent, size: 18),
                      SizedBox(width: 8),
                      Text('PahadiPulse Community Direct Benefit', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '100% of your booking amount goes directly to this local mountain family or certified guide, bypassing aggregator commissions.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact & Booking Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(LucideIcons.phoneCall, size: 18, color: Colors.black),
                label: Text(
                  'CALL / BOOK DIRECT: ${p.contactPhone}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling host ${p.ownerName} at ${p.contactPhone}...'),
                      backgroundColor: AppColors.forestGlow,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
