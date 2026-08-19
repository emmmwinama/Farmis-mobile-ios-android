import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';

/// A real animated shimmer placeholder, replacing the static gray blocks
/// (`_ShimmerBox`/`_XSkeleton`) that individual screens used to hand-roll.
class FarmioShimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const FarmioShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? FarmioColors.darkBorder : FarmioColors.slate200;
    final highlight = dark ? FarmioColors.darkCard : FarmioColors.slate50;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A card-shaped skeleton row (icon block + two text lines) for list
/// screens — the shape most `_XSkeleton` widgets across the app repeat by
/// hand today.
class FarmioShimmerCard extends StatelessWidget {
  final double height;

  const FarmioShimmerCard({super.key, this.height = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FarmioShimmer(width: 42, height: 42, radius: AppRadius.sm),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                FarmioShimmer(width: 140, height: 14),
                SizedBox(height: AppSpacing.sm),
                FarmioShimmer(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
