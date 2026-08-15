import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FarmioBadge extends StatelessWidget {
  final String  label;
  final Color   color;
  final Color?  textColor;
  final double  fontSize;

  const FarmioBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize:   fontSize,
            fontWeight: FontWeight.w700,
            color:      textColor ?? color,
          )),
    );
  }
}

class FarmioStatusBadge extends StatelessWidget {
  final String status;
  const FarmioStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'Active':    return FarmioColors.success;
      case 'Harvested': return FarmioColors.info;
      case 'Failed':    return FarmioColors.danger;
      case 'Archived':  return FarmioColors.textMuted;
      default:          return FarmioColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FarmioBadge(label: status, color: _color);
  }
}
