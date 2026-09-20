import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/destination.dart';
import '../../models/prediction.dart';
import '../../services/api_service.dart';
import '../reports/report_issue_screen.dart';
import '../planner/trip_planner_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final ApiService _api = ApiService();
  DestinationPrediction? _prediction;
  Map<String, dynamic>? _pressureDetail;
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingPrediction = true;
  int _selectedHorizon = 3;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoadingPrediction = true);
    final pred = await _api.getDestinationPrediction(widget.destination.id, horizonDays: _selectedHorizon);
    final detail = await _api.getDestinationPressureDetail(widget.destination.id);
    final hist = await _api.getDestinationHistory(widget.destination.id, days: 7);

    if (mounted) {
      setState(() {
        _prediction = pred;
        _pressureDetail = detail;
        _history = hist;
        _isLoadingPrediction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final d = widget.destination;
    final isSaved = appState.isSaved(d.id);

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      body: CustomScrollView(
        slivers: [
          // Sliver Hero Image App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.forestDark,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSaved ? LucideIcons.bookmark : LucideIcons.bookmark,
                    color: isSaved ? AppColors.forestAccent : Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () => appState.toggleSaveDestination(d.id),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    d.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.forestGlow,
                      child: const Center(child: Icon(LucideIcons.mountain, size: 64, color: AppColors.forestAccent)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.forestDark.withOpacity(0.9),
                          AppColors.forestDark,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: d.statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            d.statusBadgeLabel,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${d.district}, Uttarakhand • Altitude: ${d.altitudeMeters}m',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Carrying Capacity Overview Card
                  _buildCapacityCard(d),
                  const SizedBox(height: 20),

                  // 2. 5-Factor Pressure Telemetry Breakdown
                  _buildPressureBreakdownCard(d),
                  const SizedBox(height: 20),

                  // 3. ML Future Pressure Predictor Widget
                  _buildMLForecastWidget(d),
                  const SizedBox(height: 20),

                  // 4. Description & Overview
                  const Text('About Destination', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    d.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // 5. Popular Spots
                  if (d.popularSpots.isNotEmpty) ...[
                    const Text('Key Attractions & Spots', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: d.popularSpots.map((spot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.forestCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.compass, size: 12, color: AppColors.forestAccent),
                              const SizedBox(width: 6),
                              Text(spot, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 6. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.statusHigh,
                            side: const BorderSide(color: AppColors.statusHigh),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.alertTriangle, size: 16),
                          label: const Text('Report Issue Here'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReportIssueScreen(preselectedDestinationId: d.id),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.black),
                          label: const Text('Plan Trip Here', style: TextStyle(fontWeight: FontWeight.w800)),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(Destination d) {
    final loadRatio = d.capacityDailyTourists > 0 ? (d.currentVisitorsEst / d.capacityDailyTourists) : 0.0;
    final isOverCapacity = loadRatio > 1.0;

    return Container(
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
              const Icon(LucideIcons.users, size: 18, color: AppColors.forestAccent),
              const SizedBox(width: 8),
              const Text('Carrying Capacity & Load', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Text(
                '${(loadRatio * 100).toInt()}% Load',
                style: TextStyle(
                  color: isOverCapacity ? AppColors.statusCritical : AppColors.forestAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn('Daily Capacity', '${d.capacityDailyTourists} visitors'),
              _buildMetricColumn('Current Active Est.', '${d.currentVisitorsEst} tourists'),
              _buildMetricColumn('Budget Index', '₹${d.avgDailyBudgetINR.toInt()}/day'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: loadRatio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.forestDark,
              valueColor: AlwaysStoppedAnimation<Color>(isOverCapacity ? AppColors.statusCritical : AppColors.forestAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }

  Widget _buildPressureBreakdownCard(Destination d) {
    final exp = _pressureDetail?['explanation'] ??
        "Regional infrastructure metrics evaluated across water demand, solid waste capacity, road congestion, and seasonal risks.";

    return Container(
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
              const Icon(LucideIcons.gauge, size: 18, color: AppColors.pineTeal),
              const SizedBox(width: 8),
              const Text('5-Factor Pressure Breakdown', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Text(
                '${d.pressureScore.toInt()}/100',
                style: TextStyle(color: d.statusColor, fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildScoreBar('Tourism & Crowd Density (30%)', d.tourismScore),
          _buildScoreBar('Water Stress Index (25%)', d.waterScore),
          _buildScoreBar('Solid Waste Accumulation (20%)', d.wasteScore),
          _buildScoreBar('Traffic & Transit Bottlenecks (15%)', d.trafficScore),
          _buildScoreBar('Seasonal & Slope Hazard (10%)', d.environmentScore),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.forestDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.info, size: 14, color: AppColors.pineTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exp,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score) {
    Color col = score >= 70 ? AppColors.statusCritical : (score >= 50 ? AppColors.statusHigh : (score >= 30 ? AppColors.statusModerate : AppColors.statusLow));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text('${score.toInt()}%', style: TextStyle(color: col, fontWeight: FontWeight.w700, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (score / 100.0).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppColors.forestDark,
              valueColor: AlwaysStoppedAnimation<Color>(col),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMLForecastWidget(Destination d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.forestCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.forestAccent.withOpacity(0.6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 18, color: AppColors.forestAccent),
              const SizedBox(width: 8),
              const Text('ML Pressure Forecast', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.forestGlow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('AI REGRESSION', style: TextStyle(color: AppColors.forestAccent, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingPrediction)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestAccent)))
          else if (_prediction != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Predicted Score', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '${_prediction!.predictedScore}/100',
                        style: TextStyle(color: _prediction!.riskColor, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '95% CI: ${_prediction!.confLower} - ${_prediction!.confUpper}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Primary Driver', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        _prediction!.primaryRiskFactor,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Confidence: ${(_prediction!.modelConfidence * 100).toInt()}%',
                        style: const TextStyle(color: AppColors.pineTeal, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [1, 3, 7].map((h) {
                final isSel = _selectedHorizon == h;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('+$h Days'),
                    selected: isSel,
                    selectedColor: AppColors.forestAccent,
                    backgroundColor: AppColors.forestDark,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedHorizon = h);
                      _fetchDetails();
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
