import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/destination.dart';
import '../../models/report.dart';
import '../../models/provider.dart';
import '../destination/destination_detail_screen.dart';
import '../experiences/provider_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Selected Marker Item
  Destination? _selectedDestination;
  Report? _selectedReport;
  LocalProvider? _selectedProvider;

  // Layer Toggles
  bool _showDestinations = true;
  bool _showReports = true;
  bool _showProviders = true;

  // Filters
  String _districtFilter = 'ALL';
  String _pressureFilter = 'ALL';
  bool _isLegendExpanded = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allDestinations = appState.destinations;
    final allReports = appState.allReports.isNotEmpty ? appState.allReports : appState.myReports;
    final allProviders = appState.providers;

    // Filtered Destinations
    final filteredDestinations = allDestinations.filterDestinations(
      district: _districtFilter,
      pressureStatus: _pressureFilter,
    );

    // Filtered Reports
    final filteredReports = allReports.where((r) {
      if (_districtFilter != 'ALL') {
        // Match destination if district matches
        final dest = allDestinations.firstWhere(
          (d) => d.id == r.destinationId || d.name.toLowerCase() == r.destinationName.toLowerCase(),
          orElse: () => Destination(
            id: '', name: '', district: '', latitude: 0, longitude: 0, description: '',
            altitudeMeters: 0, capacityDailyTourists: 0, currentVisitorsEst: 0,
            tourismScore: 0, waterScore: 0, wasteScore: 0, trafficScore: 0, environmentScore: 0,
            pressureScore: 0, status: 'LOW',
            tags: [], popularSpots: [], avgDailyBudgetINR: 0, imageUrl: '',
          ),
        );
        if (dest.district.isNotEmpty && dest.district != _districtFilter) return false;
      }
      return true;
    }).toList();

    // Filtered Providers
    final filteredProviders = allProviders.where((p) {
      if (_districtFilter != 'ALL') {
        final dest = allDestinations.firstWhere(
          (d) => d.id == p.destinationId || d.name.toLowerCase() == p.destinationName.toLowerCase(),
          orElse: () => Destination(
            id: '', name: '', district: '', latitude: 0, longitude: 0, description: '',
            altitudeMeters: 0, capacityDailyTourists: 0, currentVisitorsEst: 0,
            tourismScore: 0, waterScore: 0, wasteScore: 0, trafficScore: 0, environmentScore: 0,
            pressureScore: 0, status: 'LOW',
            tags: [], popularSpots: [], avgDailyBudgetINR: 0, imageUrl: '',
          ),
        );
        if (dest.district.isNotEmpty && dest.district != _districtFilter) return false;
      }
      return true;
    }).toList();

    final districts = ['ALL', ...toUniqueList(allDestinations.map((d) => d.district).where((d) => d.isNotEmpty).toList())];

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Uttarakhand Live Telemetry Map'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.locate, color: AppColors.forestAccent),
            tooltip: 'Center Uttarakhand',
            onPressed: () {
              _mapController.move(const LatLng(30.1500, 78.8500), 8.0);
            },
          ),
          IconButton(
            icon: Icon(
              _isLegendExpanded ? LucideIcons.info : LucideIcons.layers,
              color: AppColors.forestAccent,
            ),
            tooltip: 'Toggle Layer & Legend',
            onPressed: () {
              setState(() => _isLegendExpanded = !_isLegendExpanded);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. FlutterMap OpenStreetMap Layer
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(30.1500, 78.8500),
              initialZoom: 8.0,
              minZoom: 6.5,
              maxZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.pahadipulse.tourist',
              ),

              // 1. Destination Pressure Markers
              if (_showDestinations)
                MarkerLayer(
                  markers: filteredDestinations.map((d) {
                    final isSelected = _selectedDestination?.id == d.id;
                    return Marker(
                      point: LatLng(d.latitude, d.longitude),
                      width: isSelected ? 64 : 52,
                      height: isSelected ? 64 : 52,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDestination = d;
                            _selectedReport = null;
                            _selectedProvider = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(d.status),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : _getStatusBorderColor(d.status),
                              width: isSelected ? 3.0 : 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusBorderColor(d.status).withOpacity(0.6),
                                blurRadius: isSelected ? 14 : 8,
                                spreadRadius: isSelected ? 3 : 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getStatusIcon(d.status),
                                size: isSelected ? 16 : 13,
                                color: Colors.white,
                              ),
                              Text(
                                '${d.pressureScore.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _getStatusShortLabel(d.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 7,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              // 2. Citizen Infrastructure Report Markers
              if (_showReports)
                MarkerLayer(
                  markers: filteredReports.map((r) {
                    final isSelected = _selectedReport?.id == r.id;
                    final isCritical = r.aiSeverity >= 4;
                    return Marker(
                      point: LatLng(r.latitude, r.longitude),
                      width: isSelected ? 44 : 36,
                      height: isSelected ? 44 : 36,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReport = r;
                            _selectedDestination = null;
                            _selectedProvider = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: (isCritical ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)).withOpacity(0.7),
                                blurRadius: isSelected ? 12 : 6,
                              )
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getReportCategoryIcon(r.aiCategory),
                              color: Colors.white,
                              size: isSelected ? 20 : 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              // 3. Local Community Provider Markers
              if (_showProviders)
                MarkerLayer(
                  markers: filteredProviders.map((p) {
                    final isSelected = _selectedProvider?.id == p.id;
                    return Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: isSelected ? 42 : 34,
                      height: isSelected ? 42 : 34,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProvider = p;
                            _selectedDestination = null;
                            _selectedReport = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.6),
                                blurRadius: isSelected ? 12 : 6,
                              )
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getProviderCategoryIcon(p.category),
                              color: Colors.white,
                              size: isSelected ? 18 : 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          // 2. Top Filter Chips & Layer Bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Layer: Destinations
                  FilterChip(
                    avatar: Icon(LucideIcons.compass, size: 14, color: _showDestinations ? Colors.white : AppColors.textMuted),
                    label: Text('Destinations (${filteredDestinations.length})'),
                    selected: _showDestinations,
                    onSelected: (val) => setState(() => _showDestinations = val),
                    selectedColor: AppColors.forestAccent.withOpacity(0.3),
                    checkmarkColor: AppColors.forestAccent,
                    backgroundColor: AppColors.forestDark.withOpacity(0.9),
                    labelStyle: TextStyle(
                      color: _showDestinations ? Colors.white : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Layer: Reports
                  FilterChip(
                    avatar: Icon(LucideIcons.alertTriangle, size: 14, color: _showReports ? const Color(0xFFEF4444) : AppColors.textMuted),
                    label: Text('Reports (${filteredReports.length})'),
                    selected: _showReports,
                    onSelected: (val) => setState(() => _showReports = val),
                    selectedColor: const Color(0xFFEF4444).withOpacity(0.3),
                    checkmarkColor: const Color(0xFFEF4444),
                    backgroundColor: AppColors.forestDark.withOpacity(0.9),
                    labelStyle: TextStyle(
                      color: _showReports ? Colors.white : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Layer: Providers
                  FilterChip(
                    avatar: Icon(LucideIcons.home, size: 14, color: _showProviders ? const Color(0xFF10B981) : AppColors.textMuted),
                    label: Text('Homestays (${filteredProviders.length})'),
                    selected: _showProviders,
                    onSelected: (val) => setState(() => _showProviders = val),
                    selectedColor: const Color(0xFF10B981).withOpacity(0.3),
                    checkmarkColor: const Color(0xFF10B981),
                    backgroundColor: AppColors.forestDark.withOpacity(0.9),
                    labelStyle: TextStyle(
                      color: _showProviders ? Colors.white : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // District Dropdown Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestDark.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _districtFilter,
                        dropdownColor: AppColors.forestDark,
                        icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textMuted),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        items: districts.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d == 'ALL' ? 'All Districts' : d),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _districtFilter = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Expandable Pressure Tier Legend Overlay
          if (_isLegendExpanded)
            Positioned(
              top: 60,
              left: 12,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.forestDark.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.forestAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PRESSURE TIERS & ICONS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900)),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _isLegendExpanded = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(const Color(0xFF10B981), LucideIcons.checkCircle2, '0-30 LOW (Optimal Eco-Capacity)'),
                    _buildLegendItem(const Color(0xFFF59E0B), LucideIcons.gauge, '31-50 MODERATE (Steady Footfall)'),
                    _buildLegendItem(const Color(0xFFF97316), LucideIcons.flame, '51-70 HIGH (Transit Congestion)'),
                    _buildLegendItem(const Color(0xFFEF4444), LucideIcons.alertOctagon, '71-100 CRITICAL (Bottleneck/Cap Limit)'),
                    const Divider(color: AppColors.borderSubtle, height: 16),
                    const Text('MAP LAYERS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    _buildLayerLegendItem(const Color(0xFF10B981), LucideIcons.compass, 'Destination Carrying Capacity'),
                    _buildLayerLegendItem(const Color(0xFFEF4444), LucideIcons.alertTriangle, 'Citizen Infrastructure Incidents'),
                    _buildLayerLegendItem(const Color(0xFF14B8A6), LucideIcons.home, 'Verified Local Homestays & Guides'),
                  ],
                ),
              ),
            ),

          // 4. Zoom and Center Controls
          Positioned(
            right: 12,
            bottom: (_selectedDestination != null || _selectedReport != null || _selectedProvider != null) ? 190 : 20,
            child: Column(
              children: [
                _buildMapActionButton(LucideIcons.plus, () {
                  final zoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, zoom + 1);
                }),
                const SizedBox(height: 8),
                _buildMapActionButton(LucideIcons.minus, () {
                  final zoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, zoom - 1);
                }),
                const SizedBox(height: 8),
                _buildMapActionButton(LucideIcons.compass, () {
                  _mapController.move(const LatLng(30.1500, 78.8500), 8.0);
                }),
              ],
            ),
          ),

          // 5. Bottom Detail Cards
          if (_selectedDestination != null)
            Positioned(
              bottom: 16,
              left: 14,
              right: 14,
              child: _buildDestinationCard(_selectedDestination!),
            ),

          if (_selectedReport != null)
            Positioned(
              bottom: 16,
              left: 14,
              right: 14,
              child: _buildReportCard(_selectedReport!),
            ),

          if (_selectedProvider != null)
            Positioned(
              bottom: 16,
              left: 14,
              right: 14,
              child: _buildProviderCard(_selectedProvider!),
            ),
        ],
      ),
    );
  }

  Widget _buildMapActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.forestDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.forestAccent),
      ),
    );
  }

  Widget _buildLegendItem(Color color, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, size: 11, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerLegendItem(Color color, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // Destination Bottom Card
  Widget _buildDestinationCard(Destination d) {
    final capLimit = d.capacityDailyTourists > 0 ? d.capacityDailyTourists : 10000;
    final loadRatio = ((d.currentVisitorsEst / capLimit) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusBorderColor(d.status), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  d.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.forestGlow,
                    child: const Icon(LucideIcons.mountain, color: AppColors.forestAccent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            d.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
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
                      '${d.district} District • Alt: ${d.altitudeMeters}m',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(d.status),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _getStatusBorderColor(d.status)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(d.status), size: 11, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '${d.pressureScore.toInt()}% ${d.status}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Load: $loadRatio%',
                          style: TextStyle(
                            color: loadRatio > 100 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            fontSize: 11,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.navigation, size: 13),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.forestAccent,
                    side: const BorderSide(color: AppColors.forestAccent),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    _openNavigationDirections(d.latitude, d.longitude, d.name);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.eye, size: 13),
                  label: const Text('Full Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Citizen Report Bottom Card
  Widget _buildReportCard(Report r) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getReportCategoryIcon(r.aiCategory), size: 12, color: const Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Text(
                      '${r.aiCategory} INCIDENT',
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Sev ${r.aiSeverity}/5',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _selectedReport = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.description,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${r.status} • in ${r.destinationName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              Text(
                'AI Conf: ${(r.aiConfidence * 100).toInt()}%',
                style: const TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Provider Bottom Card
  Widget _buildProviderCard(LocalProvider p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  p.categoryLabel,
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              if (p.verified)
                const Row(
                  children: [
                    Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 2),
                    Text('Verified Host', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _selectedProvider = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.name,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${p.locationAddress} (${p.destinationName})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${p.priceStartingINR.toInt()} /${p.pricingUnit}',
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w900),
              ),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.eye, size: 12),
                label: const Text('View Experience'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProviderDetailScreen(provider: p)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openNavigationDirections(double lat, double lng, String name) async {
    final uri = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=14/$lat/$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Pressure Helper Methods
  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'LOW':
        return const Color(0xFF064E3B);
      case 'MODERATE':
        return const Color(0xFF78350F);
      case 'HIGH':
        return const Color(0xFF7C2D12);
      case 'CRITICAL':
        return const Color(0xFF7F1D1D);
      default:
        return const Color(0xFF064E3B);
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status.toUpperCase()) {
      case 'LOW':
        return const Color(0xFF10B981);
      case 'MODERATE':
        return const Color(0xFFF59E0B);
      case 'HIGH':
        return const Color(0xFFF97316);
      case 'CRITICAL':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'LOW':
        return LucideIcons.checkCircle2;
      case 'MODERATE':
        return LucideIcons.gauge;
      case 'HIGH':
        return LucideIcons.flame;
      case 'CRITICAL':
        return LucideIcons.alertOctagon;
      default:
        return LucideIcons.compass;
    }
  }

  String _getStatusShortLabel(String status) {
    switch (status.toUpperCase()) {
      case 'LOW':
        return 'LOW';
      case 'MODERATE':
        return 'MOD';
      case 'HIGH':
        return 'HIGH';
      case 'CRITICAL':
        return 'CRIT';
      default:
        return 'LOW';
    }
  }

  IconData _getReportCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'WATER':
        return LucideIcons.droplets;
      case 'WASTE':
        return LucideIcons.trash2;
      case 'ROAD':
        return LucideIcons.truck;
      case 'TRAFFIC':
        return LucideIcons.car;
      case 'HEALTH':
        return LucideIcons.activity;
      case 'ENVIRONMENT':
        return LucideIcons.trees;
      default:
        return LucideIcons.alertTriangle;
    }
  }

  IconData _getProviderCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'HOMESTAY':
        return LucideIcons.home;
      case 'LOCAL_GUIDE':
        return LucideIcons.compass;
      case 'LOCAL_FOOD':
        return LucideIcons.utensils;
      case 'HANDICRAFTS':
        return LucideIcons.scissors;
      case 'RENTAL':
        return LucideIcons.bike;
      default:
        return LucideIcons.store;
    }
  }
}

// Helpers
extension on List<Destination> {
  List<Destination> filterDestinations({required String district, required String pressureStatus}) {
    return where((d) {
      final matchDistrict = district == 'ALL' || d.district.toLowerCase() == district.toLowerCase();
      final matchStatus = pressureStatus == 'ALL' || d.status.toUpperCase() == pressureStatus.toUpperCase();
      return matchDistrict && matchStatus;
    }).toList();
  }
}

List<T> toUniqueList<T>(List<T> items) {
  return items.toSet().toList();
}
