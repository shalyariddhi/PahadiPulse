import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  bool _isSuccess = false;

  bool _highPressureAlerts = true;
  bool _ecoRouteSuggestions = true;
  bool _offlineFallback = true;
  int _predictionHorizon = 3;

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiService().baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse('${_urlController.text.trim()}/region/pressure');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      stopwatch.stop();

      if (res.statusCode == 200) {
        setState(() {
          _isTesting = false;
          _isSuccess = true;
          _testResult = 'Connected to FastAPI Backend in ${stopwatch.elapsedMilliseconds}ms';
        });
        ApiService().setBaseUrl(_urlController.text.trim());
        if (mounted) {
          Provider.of<AppState>(context, listen: false).loadInitialData();
        }
      } else {
        setState(() {
          _isTesting = false;
          _isSuccess = false;
          _testResult = 'Server returned HTTP ${res.statusCode}';
        });
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isTesting = false;
        _isSuccess = false;
        _testResult = 'Connection failed: ${e.toString().split(':').last.trim()}';
      });
    }
  }

  void _applyPreset(String url) {
    _urlController.text = url;
    ApiService().setBaseUrl(url);
    _testConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section: Backend Connectivity
          _buildSectionHeader('BACKEND & API CONFIGURATION', LucideIcons.server),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forestCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FastAPI Gateway URL',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Change when running on real device (WiFi IP) or Android Emulator.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'http://localhost:8000/api',
                          filled: true,
                          fillColor: AppColors.forestDark,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isTesting ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestAccent,
                        foregroundColor: AppColors.forestDark,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isTesting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestDark))
                          : const Text('Test', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
                if (_testResult != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isSuccess ? AppColors.statusLow.withOpacity(0.15) : AppColors.statusCritical.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isSuccess ? AppColors.statusLow : AppColors.statusCritical),
                    ),
                    child: Row(
                      children: [
                        Icon(_isSuccess ? LucideIcons.checkCircle : LucideIcons.alertCircle, size: 14, color: _isSuccess ? AppColors.statusLow : AppColors.statusCritical),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testResult!,
                            style: TextStyle(color: _isSuccess ? AppColors.statusLow : AppColors.statusCritical, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Text('Quick Presets:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip('PC / Web (localhost)', AppConstants.localhostUrl),
                    _buildPresetChip('Android Emulator (10.0.2.2)', AppConstants.androidEmulatorUrl),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: ML & Prediction Engine
          _buildSectionHeader('AI & ML PREDICTION ENGINE', LucideIcons.cpu),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forestCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Default Prediction Horizon',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Forecast carrying capacity saturation up to 7 days ahead using GradientBoostingRegressor ML.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildHorizonChoice(1, '24 Hours'),
                    const SizedBox(width: 8),
                    _buildHorizonChoice(3, '3 Days'),
                    const SizedBox(width: 8),
                    _buildHorizonChoice(7, '7 Days'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Notifications & Smart Advisory
          _buildSectionHeader('NOTIFICATIONS & SMART ADVISORIES', LucideIcons.bell),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.forestCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: AppColors.forestAccent,
                  value: _highPressureAlerts,
                  title: const Text('High-Pressure Destination Alerts', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Get notified when popular spots reach CRITICAL status', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  onChanged: (val) => setState(() => _highPressureAlerts = val),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                SwitchListTile(
                  activeColor: AppColors.forestAccent,
                  value: _ecoRouteSuggestions,
                  title: const Text('Eco-Circuit Route Suggestions', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Prioritize community homestays and zero-strain paths', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  onChanged: (val) => setState(() => _ecoRouteSuggestions = val),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                SwitchListTile(
                  activeColor: AppColors.forestAccent,
                  value: _offlineFallback,
                  title: const Text('Offline Resilience Cache', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Keep cached telemetry during mountain cellular blackouts', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  onChanged: (val) => setState(() => _offlineFallback = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Cache & Diagnostics
          _buildSectionHeader('DIAGNOSTICS & MEMORY', LucideIcons.hardDrive),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forestCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                _buildDiagnosticRow('FastAPI Engine', 'v0.110.0 (Python 3.11)'),
                const SizedBox(height: 8),
                _buildDiagnosticRow('ML Inference', 'Joblib Regressor (100% Online)'),
                const SizedBox(height: 8),
                _buildDiagnosticRow('Geo Provider', 'OpenStreetMap / Leaflet Tile CDN'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Provider.of<AppState>(context, listen: false).loadInitialData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache re-synchronized with live backend.'),
                          backgroundColor: AppColors.forestAccent,
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.forestAccent),
                    label: const Text('Purge Cache & Reload Telemetry', style: TextStyle(color: AppColors.forestAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.forestAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.forestAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, String url) {
    final isSelected = _urlController.text.trim() == url;
    return InkWell(
      onTap: () => _applyPreset(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestAccent.withOpacity(0.15) : AppColors.forestDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.forestAccent : AppColors.borderSubtle),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.forestAccent : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizonChoice(int days, String label) {
    final isSelected = _predictionHorizon == days;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _predictionHorizon = days),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.forestAccent : AppColors.forestDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.forestAccent : AppColors.borderSubtle),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.forestDark : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
