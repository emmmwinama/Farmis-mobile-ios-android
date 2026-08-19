import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Standard inline error banner for forms — keeps validation/API error
/// styling identical everywhere instead of each screen hand-rolling its
/// own red container.
class FarmioErrorBanner extends StatelessWidget {
  final String message;

  const FarmioErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FarmioColors.dangerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FarmioColors.danger.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 16, color: FarmioColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: FarmioColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
