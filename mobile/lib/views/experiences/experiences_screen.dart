import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/provider.dart';
import 'provider_detail_screen.dart';

class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  String _selectedCategory = 'ALL';
  final List<String> _categories = ['ALL', 'HOMESTAY', 'LOCAL_GUIDE', 'LOCAL_FOOD', 'HANDICRAFT', 'FARM_EXPERIENCE'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allProviders = appState.providers;

    final filtered = allProviders.where((p) {
      if (_selectedCategory == 'ALL') return true;
      return p.category.toUpperCase() == _selectedCategory.toUpperCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Local Mountain Experiences'),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSel = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat.replaceAll('_', ' ')),
                  selected: isSel,
                  selectedColor: AppColors.forestAccent,
                  backgroundColor: AppColors.forestCard,
                  side: BorderSide(color: isSel ? AppColors.forestAccent : AppColors.borderSubtle),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Provider List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.home, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text('No providers found in this category', style: TextStyle(color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => setState(() => _selectedCategory = 'ALL'),
                          child: const Text('View All Providers', style: TextStyle(color: AppColors.forestAccent)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final prov = filtered[idx];
                      return _buildProviderCard(context, prov);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, LocalProvider p) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProviderDetailScreen(provider: p)),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forestGlow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.forestAccent.withOpacity(0.5)),
                  ),
                  child: Icon(
                    p.isHomestay ? LucideIcons.home : (p.isGuide ? LucideIcons.compass : LucideIcons.utensils),
                    color: AppColors.forestAccent,
                    size: 24,
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
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (p.isCertified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.forestGlow,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.forestAccent),
                              ),
                              child: const Text('VERIFIED', style: TextStyle(color: AppColors.forestAccent, fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${p.destinationName} • Hosted by ${p.ownerName}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              p.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text('${p.rating} (${p.reviewCount})', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text(
                  'From ₹${p.priceStartingINR.toInt()}',
                  style: const TextStyle(color: AppColors.forestAccent, fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
