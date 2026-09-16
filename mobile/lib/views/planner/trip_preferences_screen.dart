import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class TripPreferencesScreen extends StatefulWidget {
  const TripPreferencesScreen({super.key});

  @override
  State<TripPreferencesScreen> createState() => _TripPreferencesScreenState();
}

class _TripPreferencesScreenState extends State<TripPreferencesScreen> {
  String _travelPace = 'Relaxed'; // Relaxed, Active, Extreme
  String _stayType = 'Village Homestays'; // Village Homestays, Eco-Lodges, Riverside Camps
  bool _preferVegetarian = true;
  bool _avoidTollGhats = false;
  bool _enableOffbeatAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Travel Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Optimization Style',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Customize algorithm parameters for your Uttarakhand travel pace',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Pace
            _buildSectionTitle('Travel Pace'),
            const SizedBox(height: 8),
            Row(
              children: ['Relaxed', 'Balanced', 'Active Trekking'].map((pace) {
                final isSel = _travelPace == pace;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(pace),
                      selected: isSel,
                      selectedColor: AppColors.forestAccent,
                      backgroundColor: AppColors.forestCard,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) => setState(() => _travelPace = pace),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Stay Type
            _buildSectionTitle('Preferred Stay Format'),
            const SizedBox(height: 8),
            Column(
              children: [
                _buildRadioTile('Certified Village Homestays', '100% revenue goes to local mountain families', 'Village Homestays'),
                _buildRadioTile('Forest Eco-Lodges & Sanctuaries', 'Solar-powered low-impact wooden cabins', 'Eco-Lodges'),
                _buildRadioTile('Alpine Riverside Camps & Glamping', 'Tents along pristine Bhagirathi/Alaknanda rivers', 'Riverside Camps'),
              ],
            ),
            const SizedBox(height: 24),

            // Switches
            _buildSectionTitle('Eco & Transit Filters'),
            const SizedBox(height: 8),
            _buildSwitchTile('Organic Traditional Pahadi Food Only', 'Mandua roti, Bhatt ki churkani, herbal teas', _preferVegetarian, (v) => setState(() => _preferVegetarian = v)),
            _buildSwitchTile('Bypass Known Weekend Choke Ghats', 'Auto-reroute when Mussoorie/Nainital reach >70% pressure', _avoidTollGhats, (v) => setState(() => _avoidTollGhats = v)),
            _buildSwitchTile('Enable Real-Time Eco Suggestions', 'Notify when nearby lower-pressure hidden gems have open homestays', _enableOffbeatAlerts, (v) => setState(() => _enableOffbeatAlerts = v)),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferences saved! Applied to AI itinerary generator.'),
                      backgroundColor: AppColors.forestGlow,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700));
  }

  Widget _buildRadioTile(String title, String subtitle, String value) {
    final isSel = _stayType == value;
    return GestureDetector(
      onTap: () => setState(() => _stayType = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.forestCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? AppColors.forestAccent : AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(
              isSel ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSel ? AppColors.forestAccent : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: val,
            activeColor: AppColors.forestAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
