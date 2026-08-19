import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The single consistent AgriVault brand mark — a gradient rounded icon box.
/// Reused everywhere a logo would appear (onboarding, PIN screens, nav rail)
/// so the app has one identity instead of the divergent inline icons
/// (`Icons.agriculture_outlined` on onboarding vs `Icons.shield_outlined` on
/// the nav rail) it had before.
class BrandMark extends StatelessWidget {
  final double size;
  final double iconScale;
  final double radius;

  const BrandMark({
    super.key,
    this.size = 56,
    this.iconScale = 0.5,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FarmioColors.primary, FarmioColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.glow(FarmioColors.primary,
            blur: size * 0.36, offset: Offset(0, size * 0.14)),
      ),
      child: Icon(
        Icons.agriculture,
        color: Colors.white,
        size: size * iconScale,
      ),
    );
  }
}
