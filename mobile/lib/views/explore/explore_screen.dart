import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/destination.dart';
import '../destination/destination_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDistrict = 'ALL';
  String _selectedStatus = 'ALL';

  final List<String> _districts = [
    'ALL',
    'Dehradun',
    'Tehri Garhwal',
    'Nainital',
    'Almora',
    'Chamoli',
    'Rudraprayag',
    'Pauri Garhwal',
    'Uttarkashi',
    'Bageshwar',
    'Pithoragarh'
  ];

  final List<String> _statusFilters = ['ALL', 'LOW', 'MODERATE', 'HIGH', 'CRITICAL'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allDests = appState.destinations;

    // Apply client filtering
    final filtered = allDests.where((d) {
      final matchesSearch = _searchController.text.isEmpty ||
          d.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          d.district.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          d.tags.any((t) => t.toLowerCase().contains(_searchController.text.toLowerCase()));
      
      final matchesDistrict = _selectedDistrict == 'ALL' ||
          d.district.toLowerCase() == _selectedDistrict.toLowerCase();

      final matchesStatus = _selectedStatus == 'ALL' ||
          d.status.toUpperCase() == _selectedStatus.toUpperCase();

      return matchesSearch && matchesDistrict && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Explore Uttarakhand'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search destinations, treks, lakes, districts...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.forestCard,
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.forestAccent, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.forestAccent),
                ),
              ),
            ),
          ),

          // District Horizontal Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _districts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final dist = _districts[idx];
                final isSelected = _selectedDistrict == dist;
                return ChoiceChip(
                  label: Text(dist),
                  selected: isSelected,
                  selectedColor: AppColors.forestGlow,
                  backgroundColor: AppColors.forestCard,
                  side: BorderSide(
                    color: isSelected ? AppColors.forestAccent : AppColors.borderSubtle,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.forestAccent : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (val) => setState(() => _selectedDistrict = dist),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Status Filter Tabs
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final stat = _statusFilters[idx];
                final isSelected = _selectedStatus == stat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = stat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.forestAccent : AppColors.forestCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat == 'ALL' ? 'ALL STATUSES' : '$stat PRESSURE',
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Found ${filtered.length} Uttarakhand Destinations',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Destination List / Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.mapPinOff, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text('No destinations match your filters', style: TextStyle(color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _selectedDistrict = 'ALL';
                              _selectedStatus = 'ALL';
                            });
                          },
                          child: const Text('Reset Filters', style: TextStyle(color: AppColors.forestAccent)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final dest = filtered[idx];
                      return _buildExploreCard(context, dest);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard(BuildContext context, Destination d) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.forestCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                d.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: AppColors.forestGlow,
                  child: const Icon(LucideIcons.mountain, color: AppColors.forestAccent),
                ),
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
                          d.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: d.statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: d.statusColor, width: 1),
                        ),
                        child: Text(
                          '${d.pressureScore.toInt()}% ${d.status}',
                          style: TextStyle(
                            color: d.statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        d.district,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Text(
                        'Cap: ${d.capacityDailyTourists}',
                        style: const TextStyle(color: AppColors.pineTeal, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: d.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.forestDark,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
