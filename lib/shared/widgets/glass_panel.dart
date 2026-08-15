import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.gradient,
    this.border,
    this.shadows,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radiusValue = BorderRadius.circular(radius);
    final panel = ClipRRect(
      borderRadius: radiusValue,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radiusValue,
          gradient: gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.86),
                  FarmioColors.primaryBg.withValues(alpha: 0.46),
                  Colors.white.withValues(alpha: 0.72),
                ],
              ),
          border: border ??
              Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 1.2,
              ),
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: FarmioColors.slate900.withValues(alpha: 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.62),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
        ),
        child: child,
      ),
    );

    if (onTap == null) return panel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radiusValue,
        child: panel,
      ),
    );
  }
}

class FrostedScaffoldBackground extends StatelessWidget {
  final Widget child;

  const FrostedScaffoldBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFEFF7FC),
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: child,
    );
  }
}
