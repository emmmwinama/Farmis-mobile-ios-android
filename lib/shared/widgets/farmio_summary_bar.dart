import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// One stat shown inside a [FarmioSummaryBar].
class FarmioSummaryStat {
  final String label;
  final String value;
  final Color? color;

  const FarmioSummaryStat({
    required this.label,
    required this.value,
    this.color,
  });
}

/// The solid dark summary bar used at the top of list/detail screens
/// (matches the style already established on Employees/Reports totals).
class FarmioSummaryBar extends StatelessWidget {
  final List<FarmioSummaryStat> stats;
  final Widget? footer;

  const FarmioSummaryBar({super.key, required this.stats, this.footer});

  @override
  Widget build(BuildContext context) {
    final fill = HeroFill(
      context,
      colors: const [FarmioColors.primaryDark, FarmioColors.slate900],
      flat: FarmioColors.primaryDark,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fill.color,
        gradient: fill.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FarmioColors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < stats.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i == stats.length - 1 ? 0 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(stats[i].value,
                              maxLines: 1,
                              style: TextStyle(
                                color: stats[i].color ?? Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}
