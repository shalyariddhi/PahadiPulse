import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/destination.dart';
import '../destination/destination_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Destination? _selectedDestination;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final destinations = appState.destinations;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Live Uttarakhand Map'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.locate, color: AppColors.forestAccent),
            tooltip: 'Center Uttarakhand',
            onPressed: () {
              _mapController.move(const LatLng(30.0668, 79.0193), 8.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap OpenStreetMap tiles
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(30.1500, 78.7800),
              initialZoom: 8.0,
              minZoom: 6.0,
              maxZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.pahadipulse.tourist',
              ),
              MarkerLayer(
                markers: destinations.map((d) {
                  final isSelected = _selectedDestination?.id == d.id;
                  return Marker(
                    point: LatLng(d.latitude, d.longitude),
                    width: isSelected ? 50 : 38,
                    height: isSelected ? 50 : 38,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDestination = d);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: d.statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.black87,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: d.statusColor.withOpacity(0.5),
                              blurRadius: isSelected ? 12 : 6,
                              spreadRadius: isSelected ? 3 : 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${d.pressureScore.toInt()}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Map Legend Overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.forestDark.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PRESSURE TIERS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  _buildLegendRow(AppColors.statusLow, '0-30 Low (Eco Optimal)'),
                  _buildLegendRow(AppColors.statusModerate, '31-50 Moderate'),
                  _buildLegendRow(AppColors.statusHigh, '51-70 High Stress'),
                  _buildLegendRow(AppColors.statusCritical, '71-100 Critical Bottleneck'),
                ],
              ),
            ),
          ),

          // Selected Destination Preview Bottom Card
          if (_selectedDestination != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildSelectedDestinationCard(_selectedDestination!),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSelectedDestinationCard(Destination d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.forestAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              d.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppColors.forestGlow,
                child: const Icon(LucideIcons.mountain, color: AppColors.forestAccent),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _selectedDestination = null),
                    ),
                  ],
                ),
                Text(
                  '${d.district} • Cap: ${d.capacityDailyTourists}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: d.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: d.statusColor),
                      ),
                      child: Text(
                        '${d.pressureScore.toInt()}% ${d.status}',
                        style: TextStyle(color: d.statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)),
                        );
                      },
                      child: const Row(
                        children: [
                          Text('View Details', style: TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                          SizedBox(width: 2),
                          Icon(LucideIcons.chevronRight, size: 12, color: AppColors.forestAccent),
                        ],
                      ),
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
