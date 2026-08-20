import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  // Set alongside [gradient] (e.g. via [HeroFill]) when a caller wants a
  // flat dark-mode fill instead of translating its own gradient — takes
  // precedence over [gradient] whenever both are non-null.
  final Color? color;
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
    this.color,
    this.border,
    this.shadows,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radiusValue = BorderRadius.circular(radius);
    final isDark = context.isDark;
    // The default "glass" look is a translucent white gradient, which only
    // reads as glassmorphism against a light background — on a dark surface
    // it shows up as a washed-out light smear. Dark mode gets a flat,
    // opaque dark-card fill instead, matching the rest of the dark theme.
    final panel = ClipRRect(
      borderRadius: radiusValue,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radiusValue,
          color: color ?? (gradient == null && isDark ? context.colors.surface : null),
          gradient: color != null
              ? null
              : gradient ??
                  (isDark
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.86),
                            FarmioColors.primaryBg.withValues(alpha: 0.46),
                            Colors.white.withValues(alpha: 0.72),
                          ],
                        )),
          border: border ??
              Border.all(
                color: isDark
                    ? context.colors.border
                    : Colors.white.withValues(alpha: 0.72),
                width: 1.2,
              ),
          boxShadow: shadows ??
              (isDark
                  ? const []
                  : [
                      BoxShadow(
                        color: FarmioColors.primary.withValues(alpha: 0.1),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.62),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ]),
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
    final background = context.colors.background;
    // FarmioColors.primaryBg is a fixed light indigo tint — blending toward
    // it in dark mode produced a muddy grayish smear instead of a subtle
    // glow, so dark mode just gets the flat background color.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.isDark ? background : null,
        gradient: context.isDark
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  background,
                  Color.lerp(background, FarmioColors.primaryBg, 0.4)!,
                  background,
                ],
              ),
      ),
      child: child,
    );
  }
}
