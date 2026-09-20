import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/provider.dart';
import 'provider_detail_screen.dart';

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

/// Returns a gradient color accent for a given category
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

class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  bool _isRefreshing = false;

  static const List<Map<String, dynamic>> _categoryFilters = [
    {'key': 'ALL', 'label': 'All', 'icon': LucideIcons.layoutGrid},
    {'key': 'HOMESTAY', 'label': 'Homestays', 'icon': LucideIcons.home},
    {'key': 'LOCAL_GUIDE', 'label': 'Guides', 'icon': LucideIcons.compass},
    {'key': 'LOCAL_FOOD', 'label': 'Food', 'icon': LucideIcons.utensils},
    {'key': 'HANDICRAFTS', 'label': 'Crafts', 'icon': LucideIcons.scissors},
    {'key': 'LOCAL_PRODUCTS', 'label': 'Products', 'icon': LucideIcons.shoppingBag},
    {'key': 'CULTURAL_EXPERIENCE', 'label': 'Culture', 'icon': LucideIcons.music},
    {'key': 'RENTAL', 'label': 'Rentals', 'icon': LucideIcons.bike},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allProviders = appState.providers;

    // Apply category + search filters
    final filtered = allProviders.where((p) {
      final matchesCat = _selectedCategory == 'ALL' ||
          p.category.toUpperCase() == _selectedCategory.toUpperCase();
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.destinationName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.ownerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Local Mountain Experiences'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh providers',
            onPressed: () async {
              setState(() => _isRefreshing = true);
              await appState.fetchProviders();
              if (mounted) setState(() => _isRefreshing = false);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search experiences, hosts, locations...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.textMuted, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 16),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categoryFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categoryFilters[idx];
                final isSel = _selectedCategory == cat['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['key']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.forestAccent : AppColors.forestCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? AppColors.forestAccent : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 14,
                          color: isSel ? Colors.black : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isSel ? Colors.black : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${filtered.length} experience${filtered.length != 1 ? 's' : ''} found',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (allProviders.any((p) => p.isDemo))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.info, size: 11, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4),
                        Text(
                          'DEMO DATA',
                          style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Provider List
          Expanded(
            child: _isRefreshing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.forestAccent),
                  )
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.forestAccent,
                        backgroundColor: AppColors.forestCard,
                        onRefresh: () async {
                          await appState.fetchProviders();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, idx) {
                            final prov = filtered[idx];
                            return _buildProviderCard(context, prov);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.forestGlow.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.searchX, size: 40, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'No experiences found',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'No providers in this category yet',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(LucideIcons.layoutGrid, size: 14),
            label: const Text('View All'),
            style: TextButton.styleFrom(foregroundColor: AppColors.forestAccent),
            onPressed: () => setState(() {
              _selectedCategory = 'ALL';
              _searchQuery = '';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, LocalProvider p) {
    final catColor = _categoryAccent(p.category);

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: catColor.withOpacity(0.4)),
                  ),
                  child: Icon(
                    _categoryIcon(p.category),
                    color: catColor,
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(LucideIcons.mapPin, size: 11, color: catColor.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${p.destinationName} • ${p.categoryLabel}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                    Text(
                      '${p.rating} (${p.reviewCount})',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '₹${p.priceStartingINR.toInt()}',
                      style: TextStyle(
                        color: catColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${p.pricingUnit}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
