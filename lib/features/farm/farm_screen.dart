import 'package:flutter/material.dart';

import '../../shared/widgets/section_tab_host.dart';
import '../crops/crops_screen.dart';
import '../employees/employees_screen.dart';
import '../equipment/equipment_screen.dart';
import '../fields/fields_screen.dart';
import '../livestock/livestock_screen.dart';

/// Everything a farmer manages day to day, in one place — replaces the old
/// FarmHubScreen (a card menu) and LivestockHubScreen (whose 4 cards all
/// led to the same screen anyway). Lands on Fields, the most-used view.
class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTabHost(
      title: 'Farm',
      tabs: [
        SectionTabEntry(label: 'Fields', content: FieldsScreen(embedded: true)),
        SectionTabEntry(label: 'Crops', content: CropsScreen(embedded: true)),
        SectionTabEntry(label: 'Livestock', content: LivestockScreen(embedded: true)),
        SectionTabEntry(label: 'Equipment', content: EquipmentScreen(embedded: true)),
        SectionTabEntry(label: 'Employees', content: EmployeesScreen(embedded: true)),
      ],
    );
  }
}
