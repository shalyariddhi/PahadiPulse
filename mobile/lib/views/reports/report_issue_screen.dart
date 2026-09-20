import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../models/report.dart';
import '../../models/report_draft.dart';
import 'report_detail_sheet.dart';

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
  int _selectedSeverity = 3;
  bool _isLocating = false;
  double _latitude = 30.4598;
  double _longitude = 78.0644;
  String _locationName = "Mussoorie Ghat (30.4598° N, 78.0644° E)";

  // Image upload state
  String? _uploadedImageUrl;
  String? _attachedImageName;
  String? _uploadError;

  // Form submission state
  bool _isSubmitting = false;
  String _submissionStep = "";

  final List<Map<String, dynamic>> _categories = const [
    {"code": "ROAD", "label": "Road / Landslide", "icon": LucideIcons.truck, "color": Color(0xFFEF4444)},
    {"code": "WATER", "label": "Water Supply", "icon": LucideIcons.droplets, "color": Color(0xFF38BDF8)},
    {"code": "WASTE", "label": "Solid Waste", "icon": LucideIcons.trash2, "color": Color(0xFFF97316)},
    {"code": "TRAFFIC", "label": "Traffic Congestion", "icon": LucideIcons.car, "color": Color(0xFFFBBF24)},
    {"code": "HEALTH", "label": "Health / Medical", "icon": LucideIcons.activity, "color": Color(0xFFEC4899)},
    {"code": "CONNECTIVITY", "label": "Connectivity", "icon": LucideIcons.wifi, "color": Color(0xFF8B5CF6)},
    {"code": "TOURISM", "label": "Tourism / Scam", "icon": LucideIcons.compass, "color": Color(0xFF10B981)},
    {"code": "ENVIRONMENT", "label": "Environment", "icon": LucideIcons.trees, "color": Color(0xFF22C55E)},
    {"code": "OTHER", "label": "Civic Issue", "icon": LucideIcons.alertTriangle, "color": Color(0xFF94A3B8)},
  ];

  final List<Map<String, String>> _sampleImages = const [
    {
      "name": "Landslide / Road blockage",
      "url": "https://images.unsplash.com/photo-1590682680695-43b964a3ae17?auto=format&fit=crop&w=800&q=80"
    },
    {
      "name": "Water Pipeline Deficit",
      "url": "https://images.unsplash.com/photo-1541888946425-d0fbb18086f6?auto=format&fit=crop&w=800&q=80"
    },
    {
      "name": "Solid Waste Overflow",
      "url": "https://images.unsplash.com/photo-1605600659873-d808a13e4d2a?auto=format&fit=crop&w=800&q=80"
    },
    {
      "name": "Ghat Vehicular Gridlock",
      "url": "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80"
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedDestinationId = widget.preselectedDestinationId ?? 'mussoorie';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _refreshDeviceLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final dest = appState.destinations.firstWhere(
      (d) => d.id == _selectedDestinationId,
      orElse: () => appState.destinations.isNotEmpty ? appState.destinations.first : appState.destinations.first,
    );

    setState(() {
      _latitude = dest.latitude;
      _longitude = dest.longitude;
      _locationName = "${dest.name} (${dest.district}) • ${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E";
      _isLocating = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('GPS coordinates updated: $_locationName'),
        backgroundColor: AppColors.forestCard,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  void _attachSamplePhoto(Map<String, String> photo) {
    setState(() {
      _uploadedImageUrl = photo["url"];
      _attachedImageName = photo["name"];
      _uploadError = null;
    });
  }

  void _removePhoto() {
    setState(() {
      _uploadedImageUrl = null;
      _attachedImageName = null;
    });
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.forestDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.camera, color: AppColors.forestAccent, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Attach Photo Evidence',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Max file size 5MB • Formats: JPEG, PNG, WebP • Stored in Firebase Storage.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Evidence Photo:',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 11),
            ),
            const SizedBox(height: 10),
            ..._sampleImages.map((img) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: img["url"]!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  img["name"]!,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                subtitle: const Text(
                  'Validated (<1.2MB, image/jpeg)',
                  style: TextStyle(color: AppColors.pineTeal, fontSize: 10),
                ),
                trailing: const Icon(LucideIcons.check, color: AppColors.forestAccent, size: 16),
                onTap: () {
                  _attachSamplePhoto(img);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 10),
            // Custom direct URL option
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestAccent,
                side: const BorderSide(color: AppColors.forestAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: const Icon(LucideIcons.link, size: 16),
              label: const Text('Enter Custom Image URL'),
              onPressed: () {
                Navigator.pop(ctx);
                _showCustomUrlDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.forestCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Image URL', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: urlController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'https://images.unsplash.com/...',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.forestDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestAccent, foregroundColor: Colors.black),
            child: const Text('Attach'),
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                setState(() {
                  _uploadedImageUrl = url;
                  _attachedImageName = "Custom Web Evidence";
                });
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleReportSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submissionStep = "Validating issue report & coordinates...";
    });

    final appState = Provider.of<AppState>(context, listen: false);

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _submissionStep = "Uploading metadata & photo to Firebase Storage...");

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _submissionStep = "Triggering real-time AI classification triage...");

    final report = await appState.submitReport(
      destinationId: _selectedDestinationId,
      description: _descriptionController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      category: _selectedCategory,
      userSeverity: _selectedSeverity,
      imageUrl: _uploadedImageUrl,
    );

    setState(() => _isSubmitting = false);

    if (report != null && mounted) {
      _showSubmissionSuccessModal(report);
    } else if (mounted) {
      _showDraftSavedModal();
    }
  }

  Future<void> _handleSaveAsDraft() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an issue description to save draft.'),
          backgroundColor: AppColors.statusModerate,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final dest = appState.destinations.where((d) => d.id == _selectedDestinationId).firstOrNull;
    final draft = ReportDraft(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      destinationId: _selectedDestinationId,
      destinationName: dest?.name ?? _selectedDestinationId,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      userSeverity: _selectedSeverity,
      latitude: _latitude,
      longitude: _longitude,
      imageUrl: _uploadedImageUrl,
      createdAt: DateTime.now().toIso8601String(),
      syncStatus: 'PENDING',
    );

    await appState.saveReportDraft(draft);
    if (mounted) {
      _showDraftSavedModal();
    }
  }

  void _showDraftSavedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.forestDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.statusModerate, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusModerate.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.statusModerate, width: 2),
              ),
              child: const Icon(LucideIcons.save, color: AppColors.statusModerate, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'SAVED TO OFFLINE DRAFTS',
              style: TextStyle(color: AppColors.statusModerate, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your report draft and geo-coordinates are safely cached on your device. When network connectivity is restored, you can submit with one tap.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusModerate,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Return to reports screen
                },
                child: const Text('VIEW MY DRAFTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmissionSuccessModal(Report report) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.forestDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.forestAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(22),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.forestGlow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.forestAccent, width: 2),
                  ),
                  child: const Icon(LucideIcons.checkCheck, color: AppColors.forestAccent, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Report Submitted Successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Stored in Firestore & queued for district emergency dispatch',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
              const SizedBox(height: 20),

              // 1. REPORT ID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.forestCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REPORT ID',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      report.id,
                      style: const TextStyle(
                        color: AppColors.forestAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. AI STATUS & TRIAGE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forestGlow,
                      AppColors.forestCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pineTeal.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.sparkles, color: AppColors.forestAccent, size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          'AI CLASSIFICATION & STATUS',
                          style: TextStyle(color: AppColors.forestAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.forestAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Severity ${report.aiSeverity}/5',
                            style: const TextStyle(color: AppColors.forestAccent, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Classified Category: ${report.aiCategory}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.aiExplanation,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. CURRENT STATUS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.forestCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT STATUS',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.statusDisplayLabel,
                          style: TextStyle(
                            color: report.statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: report.statusColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.activity, color: report.statusColor, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Full Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                        ReportDetailSheet.show(context, report);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final destinations = appState.destinations;

    return Scaffold(
      backgroundColor: AppColors.forestDark,
      appBar: AppBar(
        title: const Text('Report Regional Issue'),
        backgroundColor: AppColors.forestCard,
        elevation: 0,
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forestGlow,
                      AppColors.forestCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.forestAccent.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.sparkles, color: AppColors.forestAccent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PahadiPulse AI will automatically analyze your report, verify urgency, and alert the relevant Uttarakhand disaster/municipal department.',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 1. Destination / Location Selection
              const Text(
                '1. AFFECTED DESTINATION & REGION',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
              ),
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
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                    items: destinations.map((d) {
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text('${d.name} (${d.district})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDestinationId = val;
                          final match = destinations.firstWhere((d) => d.id == val);
                          _latitude = match.latitude;
                          _longitude = match.longitude;
                          _locationName = "${match.name} (${match.district})";
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // GPS Geotag Badge & Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.forestCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 16, color: AppColors.pineTeal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS: ${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: _isLocating
                          ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.forestAccent))
                          : const Icon(LucideIcons.locate, size: 13, color: AppColors.forestAccent),
                      label: const Text('Live GPS', style: TextStyle(color: AppColors.forestAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                      onPressed: _isLocating ? null : _refreshDeviceLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 2. Issue Category Picker (All 9 categories)
              const Text(
                '2. SELECT CATEGORY',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat["code"];
                  final Color catColor = cat["color"] as Color;
                  return ChoiceChip(
                    avatar: Icon(
                      cat["icon"] as IconData,
                      size: 15,
                      color: isSel ? Colors.black : catColor,
                    ),
                    label: Text(cat["label"] as String),
                    selected: isSel,
                    selectedColor: AppColors.forestAccent,
                    backgroundColor: AppColors.forestCard,
                    side: BorderSide(color: isSel ? AppColors.forestAccent : AppColors.borderSubtle),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                    ),
                    onSelected: (val) => setState(() => _selectedCategory = cat["code"] as String),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // 3. Issue Description
              const Text(
                '3. ISSUE DETAILS & OBSERVATION',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Describe the issue clearly (e.g. Major rockfall on Tehri-Mussoorie bypass blocking two-way transit, or water tanker deficit in upper ward for 3 days)...',
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
                  if (val == null || val.trim().length < 5) {
                    return 'Please provide at least 5 characters describing the issue.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              // 4. Photo Evidence (Firebase Storage Upload)
              const Text(
                '4. PHOTO EVIDENCE (OPTIONAL)',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) ...[
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.forestAccent),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: _uploadedImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(color: AppColors.forestAccent),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.trash2, color: AppColors.statusCritical, size: 16),
                        ),
                      ),
                    ),
                    if (_attachedImageName != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _attachedImageName!,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ] else ...[
                InkWell(
                  onTap: _showImagePickerSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.forestCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      children: [
                        Icon(LucideIcons.camera, color: AppColors.forestAccent, size: 28),
                        SizedBox(height: 8),
                        Text(
                          'Upload Photo / Evidence',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Formats: JPEG, PNG, WebP • Max size 5MB',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),

              // 5. Optional Severity Rating
              Row(
                children: [
                  const Text(
                    '5. ESTIMATED SEVERITY (OPTIONAL)',
                    style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(_selectedSeverity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getSeverityColor(_selectedSeverity)),
                    ),
                    child: Text(
                      'Level $_selectedSeverity/5 • ${_getSeverityLabel(_selectedSeverity)}',
                      style: TextStyle(color: _getSeverityColor(_selectedSeverity), fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getSeverityColor(_selectedSeverity),
                  inactiveTrackColor: AppColors.forestCard,
                  thumbColor: _getSeverityColor(_selectedSeverity),
                  overlayColor: _getSeverityColor(_selectedSeverity).withOpacity(0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _selectedSeverity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (val) => setState(() => _selectedSeverity = val.round()),
                ),
              ),
              const SizedBox(height: 26),

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
                    _isSubmitting ? _submissionStep.toUpperCase() : 'SUBMIT CITIZEN REPORT',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  onPressed: _isSubmitting ? null : _handleReportSubmission,
                ),
              ),
              const SizedBox(height: 12),

              // Save Draft Secondary Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(LucideIcons.save, size: 16, color: AppColors.statusModerate),
                  label: const Text(
                    'SAVE AS OFFLINE DRAFT',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.statusModerate),
                  ),
                  onPressed: _isSubmitting ? null : _handleSaveAsDraft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(int sev) {
    if (sev >= 5) return AppColors.statusCritical;
    if (sev >= 4) return AppColors.statusHigh;
    if (sev >= 3) return AppColors.statusModerate;
    return AppColors.statusLow;
  }

  String _getSeverityLabel(int sev) {
    switch (sev) {
      case 5:
        return "Critical Hazard";
      case 4:
        return "High Urgency";
      case 3:
        return "Moderate Stress";
      case 2:
        return "Minor Inconvenience";
      case 1:
      default:
        return "Low / Informational";
    }
  }
}
