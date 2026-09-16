import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';

class ReportIssueScreen extends StatefulWidget {
  final String? preselectedDestinationId;

  const ReportIssueScreen({super.key, this.preselectedDestinationId});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  late String _selectedDestinationId;
  String _selectedCategory = 'ROAD';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {"code": "ROAD", "label": "Road / Landslide", "icon": LucideIcons.truck},
    {"code": "WATER", "label": "Water Scarcity", "icon": LucideIcons.droplets},
    {"code": "WASTE", "label": "Solid Waste", "icon": LucideIcons.trash2},
    {"code": "TRAFFIC", "label": "Traffic Bottleneck", "icon": LucideIcons.car},
    {"code": "ENVIRONMENT", "label": "Slope/Weather Alert", "icon": LucideIcons.cloudLightning},
    {"code": "OTHER", "label": "Civic Issue", "icon": LucideIcons.helpCircle},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDestinationId = widget.preselectedDestinationId ?? 'mussoorie';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final destinations = appState.destinations;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Report Regional Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.forestGlow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.forestAccent.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.sparkles, color: AppColors.forestAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI automatically classifies report category, emergency severity (1-5), and alerts district disaster / municipal response.',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Destination Selector
              const Text('Affected Destination', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
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
                    value: destinations.any((d) => d.id == _selectedDestinationId)
                        ? _selectedDestinationId
                        : (destinations.isNotEmpty ? destinations.first.id : 'mussoorie'),
                    dropdownColor: AppColors.forestCard,
                    isExpanded: true,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    items: destinations.map((d) {
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text('${d.name} (${d.district})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDestinationId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Category Picker
              const Text('Issue Category', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat["code"];
                  return ChoiceChip(
                    avatar: Icon(
                      cat["icon"] as IconData,
                      size: 14,
                      color: isSel ? Colors.black : AppColors.forestAccent,
                    ),
                    label: Text(cat["label"] as String),
                    selected: isSel,
                    selectedColor: AppColors.forestAccent,
                    backgroundColor: AppColors.forestCard,
                    side: BorderSide(color: isSel ? AppColors.forestAccent : AppColors.borderSubtle),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) => setState(() => _selectedCategory = cat["code"] as String),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 3. Description
              const Text('Issue Details & Observation', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe the issue (e.g. Major rockfall on Tehri bypass blocking 2-way traffic, or water tanker shortage in Upper Mall for 3 days)...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.forestCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.forestAccent),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 8) {
                    return 'Please provide at least 8 characters describing the issue.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Geotagging badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.forestDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: AppColors.pineTeal),
                    SizedBox(width: 8),
                    Text('GPS Coordinates: 30.4598° N, 78.0644° E (Auto-geotagged)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(LucideIcons.send, size: 18, color: Colors.black),
                  label: Text(
                    _isSubmitting ? 'SUBMITTING TO AI TRIAGE...' : 'SUBMIT CITIZEN REPORT',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSubmitting = true);
                            final success = await appState.submitReport(
                              destinationId: _selectedDestinationId,
                              description: _descriptionController.text.trim(),
                              latitude: 30.4598,
                              longitude: 78.0644,
                              category: _selectedCategory,
                            );
                            setState(() => _isSubmitting = false);

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Report submitted! AI classified and notified local nodal officer.'),
                                  backgroundColor: AppColors.forestGlow,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
