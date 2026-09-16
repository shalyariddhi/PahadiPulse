import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../itinerary/generated_itinerary_screen.dart';
import 'trip_preferences_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _days = 3;
  int _travellers = 2;
  double _budgetPerPerson = 3000.0;
  String _startingRegion = 'Dehradun / Rishikesh';

  final List<String> _availableInterests = [
    'Nature & Forests',
    'Trekking & Trails',
    'Local Homestays',
    'Peace & Quiet',
    'Colonial Heritage',
    'Photography',
    'Rivers & Waterfalls',
    'Traditional Food',
    'Spiritual Temples',
    'Snow Peaks & Skiing',
  ];

  final Set<String> _selectedInterests = {'Nature & Forests', 'Trekking & Trails', 'Local Homestays', 'Peace & Quiet'};

  final List<String> _startingRegions = [
    'Dehradun / Rishikesh',
    'Haridwar',
    'Kathgodam / Haldwani',
    'Pantnagar',
    'Delhi NCR'
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('AI Sustainable Trip Planner'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.sliders, color: AppColors.textPrimary),
            tooltip: 'Advanced Preferences',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TripPreferencesScreen()),
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
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forestGlow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.forestAccent.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.sparkles, color: AppColors.forestAccent, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI generates balanced multi-day itineraries that redirect pressure from crowded choke points to authentic mountain homestays.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Duration (Days)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trip Duration', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('$_days Days', style: const TextStyle(color: AppColors.forestAccent, fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [1, 2, 3, 4, 5, 7].map((d) {
                final isSel = _days == d;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text('$d d'),
                      selected: isSel,
                      selectedColor: AppColors.forestAccent,
                      backgroundColor: AppColors.forestCard,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      onSelected: (val) => setState(() => _days = d),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 2. Travellers Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Travellers Count', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('$_travellers Person${_travellers > 1 ? 's' : ''}', style: const TextStyle(color: AppColors.pineTeal, fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [1, 2, 3, 4, 6, 8].map((t) {
                final isSel = _travellers == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text('$t'),
                      selected: isSel,
                      selectedColor: AppColors.pineTeal,
                      backgroundColor: AppColors.forestCard,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      onSelected: (val) => setState(() => _travellers = t),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 3. Daily Budget Per Person
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Budget (Per Person / Day)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('₹${_budgetPerPerson.toInt()}', style: const TextStyle(color: AppColors.forestAccent, fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 6),
            Slider(
              value: _budgetPerPerson,
              min: 1500.0,
              max: 8000.0,
              divisions: 13,
              activeColor: AppColors.forestAccent,
              inactiveColor: AppColors.forestCard,
              onChanged: (val) => setState(() => _budgetPerPerson = val),
            ),
            const SizedBox(height: 18),

            // 4. Starting Gateway
            const Text('Starting Region / Gateway', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.forestCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _startingRegion,
                  dropdownColor: AppColors.forestCard,
                  isExpanded: true,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  items: _startingRegions.map((reg) {
                    return DropdownMenuItem<String>(
                      value: reg,
                      child: Text(reg),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _startingRegion = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Travel Interests Chips
            const Text('Travel Interests & Vibes', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  selectedColor: AppColors.forestAccent,
                  backgroundColor: AppColors.forestCard,
                  side: BorderSide(color: isSelected ? AppColors.forestAccent : AppColors.borderSubtle),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedInterests.add(interest);
                      } else {
                        if (_selectedInterests.length > 1) {
                          _selectedInterests.remove(interest);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: appState.isLoadingItinerary
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(LucideIcons.sparkles, size: 20, color: Colors.black),
                label: Text(
                  appState.isLoadingItinerary ? 'OPTIMIZING ECO CIRCUIT...' : 'GENERATE SUSTAINABLE CIRCUIT',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                ),
                onPressed: appState.isLoadingItinerary
                    ? null
                    : () async {
                        final success = await appState.planTrip(
                          days: _days,
                          travellers: _travellers,
                          budget: _budgetPerPerson,
                          interests: _selectedInterests.toList(),
                          startingRegion: _startingRegion,
                        );
                        if (success && mounted && appState.currentItinerary != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GeneratedItineraryScreen(itinerary: appState.currentItinerary!),
                            ),
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
