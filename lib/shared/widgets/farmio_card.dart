import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FarmioCard extends StatelessWidget {
  final Widget      child;
  final EdgeInsets? padding;
  final Color?      color;
  final VoidCallback? onTap;
  final double      radius;
  final Color?      borderColor;

  const FarmioCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.radius     = 14,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width:   double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? FarmioColors.softBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(radius),
          child: card,
        ),
      );
    }

    return card;
  }
}

class FarmioGradientCard extends StatelessWidget {
  final Widget        child;
  final List<Color>   colors;
  final EdgeInsets?   padding;
  final double        radius;
  final VoidCallback? onTap;

  const FarmioGradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.padding,
    this.radius = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width:   double.infinity,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color:      colors.first.withValues(alpha: 0.3),
                blurRadius: 18,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
