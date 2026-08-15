import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Fmt {
  static String mwk(double amount) {
    return 'MWK ${NumberFormat('#,##0', 'en').format(amount.round())}';
  }

  static String ha(double ha) {
    final ac = ha * 2.47105;
    return '${ha.toStringAsFixed(2)} ha (${ac.toStringAsFixed(2)} ac)';
  }

  static String haShort(double ha) => '${ha.toStringAsFixed(2)} ha';

  static String kg(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(2)} t';
    return '${kg.round()} kg';
  }

  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);

  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);

  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  static String activityIcon(String type) => activityLabel(type);

  static String activityLabel(String type) {
    switch (type.toLowerCase()) {
      case 'planting':
        return 'Planting';
      case 'fertilizing':
        return 'Fertilizing';
      case 'irrigation':
        return 'Irrigation';
      case 'weeding':
        return 'Weeding';
      case 'harvesting':
        return 'Harvesting';
      case 'spraying':
        return 'Spraying';
      default:
        return type;
    }
  }

  static IconData activityIconData(String type) {
    switch (type.toLowerCase()) {
      case 'planting':
        return Icons.grass_outlined;
      case 'fertilizing':
        return Icons.science_outlined;
      case 'irrigation':
        return Icons.water_drop_outlined;
      case 'weeding':
        return Icons.eco_outlined;
      case 'harvesting':
        return Icons.agriculture_outlined;
      case 'spraying':
        return Icons.air_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }
}
