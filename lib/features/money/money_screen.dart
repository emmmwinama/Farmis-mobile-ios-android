import 'package:flutter/material.dart';

import '../../shared/widgets/section_tab_host.dart';
import '../compliance/credit_score_screen.dart';
import '../finance/finance_screen.dart';
import '../inventory/inventory_screen.dart';

/// The farm's money picture in one place — replaces the old
/// BusinessHubScreen card menu. Lands on Finance, the most-used view.
class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTabHost(
      title: 'Money',
      tabs: [
        SectionTabEntry(label: 'Finance', content: FinanceScreen(embedded: true)),
        SectionTabEntry(label: 'Inventory', content: InventoryScreen(embedded: true)),
        SectionTabEntry(label: 'Credit', content: CreditScoreScreen(embedded: true)),
      ],
    );
  }
}
