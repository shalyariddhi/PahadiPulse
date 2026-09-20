import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class PressureBadge extends StatelessWidget {
  final double score;
  final String status;
  final bool showIcon;
  final bool compact;

  const PressureBadge({
    super.key,
    required this.score,
    required this.status,
    this.showIcon = true,
    this.compact = false,
  });

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.statusCritical;
      case 'HIGH':
        return AppColors.statusHigh;
      case 'MODERATE':
        return AppColors.statusModerate;
      case 'LOW':
      default:
        return AppColors.statusLow;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return LucideIcons.alertOctagon;
      case 'HIGH':
        return LucideIcons.alertTriangle;
      case 'MODERATE':
        return LucideIcons.info;
      case 'LOW':
      default:
        return LucideIcons.checkCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: compact ? 11 : 13, color: color),
            SizedBox(width: compact ? 3 : 5),
          ],
          Text(
            '${score.toStringAsFixed(compact ? 0 : 1)}/100',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 10 : 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9 : 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
