import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/crop_field.dart';
import '../../models/employee.dart';
import '../../shared/agronomy/crop_timeline_catalog.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import '../employees/employees_provider.dart';
import '../fields/fields_provider.dart';
import '../crops/crops_provider.dart';
import 'activities_provider.dart';

class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key});

  @override
  ConsumerState<ActivityFormScreen> createState() =>
      _ActivityFormScreenState();
}

class _ActivityFormScreenState
    extends ConsumerState<ActivityFormScreen> {
  final _notesCtrl = TextEditingController();
  final _otherActivityTypeCtrl = TextEditingController();
  final _responsiblePersonCtrl = TextEditingController();

  String?   _fieldId;
  String?   _cropFieldId;
  String    _activityType = 'Planting';
  String?   _responsibleEmployeeId;
  DateTime  _date         = DateTime.now();
  bool      _saving       = false;
  String?   _error;

  // Inputs list
  final List<Map<String, TextEditingController>> _inputs = [];

  // Labour list
  final List<_LabourEntry> _labour = [];

  // Other costs list
  final List<Map<String, TextEditingController>> _otherCosts = [];

  static const _casualWorkerValue = '__casual_worker__';

  final _defaultActivityTypes = [
    'Land preparation', 'Planting', 'Field inspection', 'Weeding',
    'Fertilizing', 'Irrigation', 'Spraying', 'Harvesting', 'Storage', 'Other',
  ];

  final _inputCategories = [
    'Seed', 'Fertilizer', 'Pesticide', 'Herbicide',
    'Fungicide', 'Equipment', 'Other',
  ];

  void _addInput() {
    setState(() {
      _inputs.add({
        'name':     TextEditingController(),
        'category': TextEditingController(text: 'Fertilizer'),
        'quantity': TextEditingController(),
        'unit':     TextEditingController(text: 'kg'),
        'unitCost': TextEditingController(),
      });
    });
  }

  void _removeInput(int i) {
    setState(() {
      for (final c in _inputs[i].values) c.dispose();
      _inputs.removeAt(i);
    });
  }

  void _addLabour() {
    setState(() => _labour.add(_LabourEntry()));
  }

  void _removeLabour(int i) {
    setState(() {
      _labour[i].dispose();
      _labour.removeAt(i);
    });
  }

  void _addOtherCost() {
    setState(() {
      _otherCosts.add({
        'description': TextEditingController(),
        'amount':      TextEditingController(),
      });
    });
  }

  void _removeOtherCost(int i) {
    setState(() {
      for (final c in _otherCosts[i].values) c.dispose();
      _otherCosts.removeAt(i);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _date,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_fieldId == null) {
      setState(() => _error = 'Please select a field.');
      return;
    }

    final activityType = _activityType == 'Other'
        ? _otherActivityTypeCtrl.text.trim()
        : _activityType;

    if (activityType.isEmpty) {
      setState(() => _error = 'Please enter the activity type.');
      return;
    }

    final responsiblePersonName =
        (_responsibleEmployeeId == _casualWorkerValue ||
                _responsibleEmployeeId == null)
            ? _responsiblePersonCtrl.text.trim()
            : '';

    setState(() { _saving = true; _error = null; });

    try {
      await ref.read(activitiesRepositoryProvider).createActivity({
        'fieldId':      _fieldId,
        'cropFieldId':  _cropFieldId,
        'activityType': activityType,
        'date':         _date.toIso8601String(),
        'notes':        _notesCtrl.text.trim(),
        'responsibleEmployeeId': _responsibleEmployeeId != null &&
                _responsibleEmployeeId != _casualWorkerValue
            ? _responsibleEmployeeId
            : null,
        'responsiblePersonName':
            responsiblePersonName.isNotEmpty ? responsiblePersonName : null,
        'inputs': _inputs.map((i) => {
          'inputName': i['name']!.text.trim(),
          'category':  i['category']!.text.trim(),
          'quantity':  i['quantity']!.text.trim(),
          'unit':      i['unit']!.text.trim(),
          'unitCost':  i['unitCost']!.text.trim(),
        }).where((i) => i['inputName']!.isNotEmpty).toList(),
        'labour': _labour.map((l) => {
          'employeeId':  l.employeeId,
          'hoursWorked': l.hoursCtrl.text.trim(),
          'daysWorked':  l.daysCtrl.text.trim(),
          'totalCost':   l.costCtrl.text.trim(),
        }).where((l) => l['employeeId'] != null).toList(),
        'otherCosts': _otherCosts.map((o) => {
          'description': o['description']!.text.trim(),
          'amount':      o['amount']!.text.trim(),
        }).where((o) => o['description']!.isNotEmpty).toList(),
      });
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Failed to save activity: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _otherActivityTypeCtrl.dispose();
    _responsiblePersonCtrl.dispose();
    for (final i in _inputs) {
      for (final c in i.values) c.dispose();
    }
    for (final l in _labour) {
      l.dispose();
    }
    for (final o in _otherCosts) {
      for (final c in o.values) c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(fieldsProvider);
    final crops  = ref.watch(cropsProvider);
    final employees = ref.watch(employeesProvider);
    final cropList = crops.valueOrNull ?? const <CropFieldModel>[];
    final activityTypes = _activityTypesForSelectedCrop(cropList);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Add activity',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Field picker
            _label('Field *'),
            fields.when(
              loading: () => const LinearProgressIndicator(),
              error:   (_, __) =>
              const Text('Failed to load fields'),
              data: (list) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color:        FarmioColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: FarmioColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:      _fieldId,
                    hint:       const Text('Select field'),
                    isExpanded: true,
                    items: list
                        .map((f) => DropdownMenuItem(
                      value: f.id,
                      child: Text(f.name),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _fieldId    = v;
                      _cropFieldId = null;
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Crop picker (optional)
            _label('Crop (optional)'),
            crops.when(
              loading: () => const LinearProgressIndicator(),
              error:   (_, __) => const SizedBox(),
              data: (list) {
                final filtered = _fieldId != null
                    ? list.where((c) => c.fieldId == _fieldId).toList()
                    : list;
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color:        FarmioColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: FarmioColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:      _cropFieldId,
                      hint:       const Text('None'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('None'),
                        ),
                        ...filtered.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                              '${c.cropTypeName} (${c.variety})'),
                        )),
                      ],
                      onChanged: (v) => setState(() {
                        _cropFieldId = v;
                        final nextTypes = _activityTypesForSelectedCrop(list);
                        if (!nextTypes.contains(_activityType)) {
                          _activityType = nextTypes.first;
                          _otherActivityTypeCtrl.clear();
                        }
                      }),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Activity type
            _label('Activity type *'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:        FarmioColors.background,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: FarmioColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:      activityTypes.contains(_activityType)
                      ? _activityType
                      : activityTypes.first,
                  isExpanded: true,
                  items:      activityTypes
                      .map((t) => DropdownMenuItem(
                      value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _activityType = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_activityType == 'Other') ...[
              _label('Other activity type *'),
              TextField(
                controller: _otherActivityTypeCtrl,
                decoration: _inputDecoration('Describe the activity'),
              ),
              const SizedBox(height: 16),
            ],

            // Responsible person
            _label('Responsible person (optional)'),
            employees.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => _ResponsiblePersonFallback(
                controller: _responsiblePersonCtrl,
              ),
              data: (list) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: FarmioColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FarmioColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _responsibleEmployeeId,
                        hint: const Text('None'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('None'),
                          ),
                          ...list.where((e) => e.isActive).map(
                                (e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.name),
                                ),
                              ),
                          const DropdownMenuItem(
                            value: _casualWorkerValue,
                            child: Text('Other / piece worker'),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _responsibleEmployeeId = v;
                          if (v != _casualWorkerValue) {
                            _responsiblePersonCtrl.clear();
                          }
                        }),
                      ),
                    ),
                  ),
                  if (_responsibleEmployeeId == _casualWorkerValue) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _responsiblePersonCtrl,
                      decoration: _inputDecoration(
                        'Enter worker or crew name',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _label('Date *'),
            InkWell(
              onTap:        _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color:        FarmioColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: FarmioColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: FarmioColors.textMuted),
                  const SizedBox(width: 10),
                  Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      color:    FarmioColors.textPrimary,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            _label('Notes (optional)'),
            TextField(
              controller: _notesCtrl,
              maxLines:   3,
              decoration: InputDecoration(
                hintText: 'Any notes about this activity...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                filled:    true,
                fillColor: context.colors.background,
              ),
            ),
            const SizedBox(height: 24),

            // Inputs section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Inputs',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.textPrimary,
                    )),
                TextButton.icon(
                  onPressed: _addInput,
                  icon:  const Icon(Icons.add, size: 16),
                  label: const Text('Add input'),
                ),
              ],
            ),
            ..._inputs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:   _InputForm(
                controllers: e.value,
                categories:  _inputCategories,
                onRemove:    () => _removeInput(e.key),
              ),
            )),

            const SizedBox(height: 8),

            // Labour section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Labour',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.textPrimary,
                    )),
                TextButton.icon(
                  onPressed: _addLabour,
                  icon:  const Icon(Icons.add, size: 16),
                  label: const Text('Add labour'),
                ),
              ],
            ),
            ..._labour.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LabourForm(
                entry: e.value,
                employees: employees.valueOrNull ?? const [],
                onEmployeeChanged: (id) =>
                    setState(() => e.value.employeeId = id),
                onRemove: () => _removeLabour(e.key),
              ),
            )),

            const SizedBox(height: 8),

            // Other costs section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Other costs',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w800,
                      color:      FarmioColors.textPrimary,
                    )),
                TextButton.icon(
                  onPressed: _addOtherCost,
                  icon:  const Icon(Icons.add, size: 16),
                  label: const Text('Add cost'),
                ),
              ],
            ),
            ..._otherCosts.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:   _OtherCostForm(
                controllers: e.value,
                onRemove:    () => _removeOtherCost(e.key),
              ),
            )),

            if (_error != null) ...[
              const SizedBox(height: 12),
              FarmioErrorBanner(message: _error!),
            ],

            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  width:  20,
                  height: 20,
                  child:  CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Save activity'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w700,
          color:      FarmioColors.textMuted,
        )),
  );

  List<String> _activityTypesForSelectedCrop(List<CropFieldModel> crops) {
    CropFieldModel? selected;
    for (final crop in crops) {
      if (crop.id == _cropFieldId) {
        selected = crop;
        break;
      }
    }
    if (selected == null) return _defaultActivityTypes;
    return CropTimelineCatalog.expectedActivityTypesFor(
      selected.cropTypeName,
    );
  }

  InputDecoration _inputDecoration(String hintText) => InputDecoration(
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.colors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.colors.border),
    ),
    filled: true,
    fillColor: context.colors.background,
  );
}

class _ResponsiblePersonFallback extends StatelessWidget {
  final TextEditingController controller;
  const _ResponsiblePersonFallback({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter worker or crew name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.border),
        ),
        filled: true,
        fillColor: context.colors.background,
      ),
    );
  }
}

// ── Input form row ────────────────────────────────────────────────────────────
class _InputForm extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final List<String>  categories;
  final VoidCallback  onRemove;

  const _InputForm({
    required this.controllers,
    required this.categories,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: _SmallField(
                controller: controllers['name']!,
                hint:       'Input name',
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon:      const Icon(Icons.close,
                  size: 18, color: FarmioColors.danger),
              onPressed: onRemove,
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _SmallField(
                controller: controllers['quantity']!,
                hint:       'Qty',
                inputType:  TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SmallField(
                controller: controllers['unit']!,
                hint:       'Unit',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SmallField(
                controller: controllers['unitCost']!,
                hint:       'Unit cost',
                inputType:  TextInputType.number,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Labour entry state + form row ───────────────────────────────────────────────
class _LabourEntry {
  String? employeeId;
  final hoursCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  final costCtrl = TextEditingController();

  void dispose() {
    hoursCtrl.dispose();
    daysCtrl.dispose();
    costCtrl.dispose();
  }
}

class _LabourForm extends StatelessWidget {
  final _LabourEntry entry;
  final List<EmployeeModel> employees;
  final ValueChanged<String?> onEmployeeChanged;
  final VoidCallback onRemove;

  const _LabourForm({
    required this.entry,
    required this.employees,
    required this.onEmployeeChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FarmioColors.border),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: FarmioColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: FarmioColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: entry.employeeId,
                    hint: const Text('Select worker',
                        style: TextStyle(fontSize: 13)),
                    isExpanded: true,
                    isDense: true,
                    style: const TextStyle(
                        fontSize: 13, color: FarmioColors.textPrimary),
                    items: employees
                        .where((e) => e.isActive)
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: onEmployeeChanged,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close,
                  size: 18, color: FarmioColors.danger),
              onPressed: onRemove,
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _SmallField(
                controller: entry.hoursCtrl,
                hint: 'Hours worked',
                inputType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SmallField(
                controller: entry.daysCtrl,
                hint: 'Days worked',
                inputType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SmallField(
                controller: entry.costCtrl,
                hint: 'Total cost',
                inputType: TextInputType.number,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Other cost form row ───────────────────────────────────────────────────────
class _OtherCostForm extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final VoidCallback onRemove;

  const _OtherCostForm({
    required this.controllers,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: FarmioColors.border),
      ),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: _SmallField(
            controller: controllers['description']!,
            hint:       'Description',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SmallField(
            controller: controllers['amount']!,
            hint:       'Amount (MWK)',
            inputType:  TextInputType.number,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon:      const Icon(Icons.close,
              size: 18, color: FarmioColors.danger),
          onPressed: onRemove,
        ),
      ]),
    );
  }
}

class _SmallField extends StatelessWidget {
  final TextEditingController controller;
  final String        hint;
  final TextInputType inputType;

  const _SmallField({
    required this.controller,
    required this.hint,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      keyboardType: inputType,
      style:        const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText:        hint,
        hintStyle:       const TextStyle(fontSize: 12),
        isDense:         true,
        contentPadding:  const EdgeInsets.symmetric(
            horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.colors.border),
        ),
        filled:    true,
        fillColor: context.colors.background,
      ),
    );
  }
}
