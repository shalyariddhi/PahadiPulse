import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/provider.dart';

/// Returns the appropriate icon for a given provider category
IconData _categoryIcon(String category) {
  switch (category.toUpperCase()) {
    case 'HOMESTAY':
      return LucideIcons.home;
    case 'LOCAL_GUIDE':
      return LucideIcons.compass;
    case 'LOCAL_FOOD':
      return LucideIcons.utensils;
    case 'HANDICRAFTS':
      return LucideIcons.scissors;
    case 'LOCAL_PRODUCTS':
      return LucideIcons.shoppingBag;
    case 'CULTURAL_EXPERIENCE':
      return LucideIcons.music;
    case 'RENTAL':
      return LucideIcons.bike;
    default:
      return LucideIcons.sparkles;
  }
}

Color _categoryAccent(String category) {
  switch (category.toUpperCase()) {
    case 'HOMESTAY':
      return const Color(0xFF10B981);
    case 'LOCAL_GUIDE':
      return const Color(0xFF14B8A6);
    case 'LOCAL_FOOD':
      return const Color(0xFFF59E0B);
    case 'HANDICRAFTS':
      return const Color(0xFFA78BFA);
    case 'LOCAL_PRODUCTS':
      return const Color(0xFF60A5FA);
    case 'CULTURAL_EXPERIENCE':
      return const Color(0xFFF472B6);
    case 'RENTAL':
      return const Color(0xFFFB923C);
    default:
      return AppColors.forestAccent;
  }
}

class ProviderDetailScreen extends StatelessWidget {
  final LocalProvider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link'),
              backgroundColor: AppColors.statusCritical,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.statusCritical,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call $phone — phone dialer unavailable on this device'),
              backgroundColor: AppColors.forestGlow,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Call host at: $phone'),
            backgroundColor: AppColors.forestGlow,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = provider;
    final catColor = _categoryAccent(p.category);

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: catColor.withOpacity(0.5)),
                        ),
                        child: Icon(
                          _categoryIcon(p.category),
                          color: catColor,
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.categoryLabel,
                                    style: TextStyle(
                                      color: catColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (p.isCertified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.forestGlow,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.forestAccent.withOpacity(0.5)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.checkCircle, size: 10, color: AppColors.forestAccent),
                                        SizedBox(width: 3),
                                        Text(
                                          'VERIFIED',
                                          style: TextStyle(
                                            color: AppColors.forestAccent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(LucideIcons.star, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  '${p.rating} (${p.reviewCount} reviews)',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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

                  // Info Grid
                  _buildInfoRow(
                    icon: LucideIcons.indianRupee,
                    label: 'Pricing',
                    value: '₹${p.priceStartingINR.toInt()} / ${p.pricingUnit}',
                    valueColor: catColor,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: LucideIcons.mapPin,
                    label: 'Location',
                    value: p.locationAddress.isNotEmpty ? p.locationAddress : p.destinationName,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: LucideIcons.user,
                    label: 'Host',
                    value: p.ownerName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              'About the Experience',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              p.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Community Direct Benefit Banner
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
                      Icon(LucideIcons.heartHandshake, color: AppColors.forestAccent, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PahadiPulse Community Direct Benefit',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
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
            const SizedBox(height: 20),

            // Contact Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact & Booking',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: LucideIcons.phone,
                    label: 'Phone',
                    value: p.contactPhone,
                  ),
                  if (p.contactEmail != null && p.contactEmail!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: LucideIcons.mail,
                      label: 'Email',
                      value: p.contactEmail!,
                    ),
                  ],
                  if (p.hasBookingUrl) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: LucideIcons.externalLink,
                      label: 'Booking Link',
                      value: 'External booking page',
                      valueColor: AppColors.pineTeal,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary CTA — External Booking or Phone Call
            if (p.hasBookingUrl) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: catColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                  icon: const Icon(LucideIcons.externalLink, size: 18, color: Colors.black),
                  label: const Text(
                    'BOOK / ENQUIRE ONLINE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  onPressed: () => _launchUrl(context, p.externalBookingUrl),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.hasBookingUrl ? AppColors.forestCard : catColor,
                  foregroundColor: p.hasBookingUrl ? AppColors.textPrimary : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: p.hasBookingUrl
                        ? const BorderSide(color: AppColors.borderSubtle)
                        : BorderSide.none,
                  ),
                ),
                icon: Icon(
                  LucideIcons.phoneCall,
                  size: 18,
                  color: p.hasBookingUrl ? AppColors.forestAccent : Colors.black,
                ),
                label: Text(
                  'CALL HOST: ${p.contactPhone}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: p.hasBookingUrl ? AppColors.textPrimary : Colors.black,
                  ),
                ),
                onPressed: () => _makePhoneCall(context, p.contactPhone),
              ),
            ),
            const SizedBox(height: 24),

            // Demo Disclaimer (transparent about synthetic data)
            if (p.isDemo)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo Provider',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.disclaimer,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
