import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import '../crops/crops_provider.dart';
import 'yields_provider.dart';

class YieldFormScreen extends ConsumerStatefulWidget {
  final String? preselectedCropFieldId;
  const YieldFormScreen({super.key, this.preselectedCropFieldId});

  @override
  ConsumerState<YieldFormScreen> createState() =>
      _YieldFormScreenState();
}

class _YieldFormScreenState extends ConsumerState<YieldFormScreen> {
  final _quantityCtrl   = TextEditingController();
  final _unitWeightCtrl = TextEditingController(text: '50');
  final _notesCtrl      = TextEditingController();

  String?  _cropFieldId;
  String   _unit        = 'bags';
  DateTime _harvestDate = DateTime.now();
  bool     _saving      = false;
  String?  _error;

  final _units = ['kg', 'bags', 'tonnes', 'crates'];

  @override
  void initState() {
    super.initState();
    _cropFieldId = widget.preselectedCropFieldId;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: _harvestDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) setState(() => _harvestDate = picked);
  }

  Future<void> _save() async {
    if (_cropFieldId == null ||
        _quantityCtrl.text.trim().isEmpty) {
      setState(() =>
      _error = 'Please select a crop and enter quantity.');
      return;
    }

    setState(() { _saving = true; _error = null; });

    try {
      final data = <String, dynamic>{
        'cropFieldId': _cropFieldId,
        'harvestDate': _harvestDate.toIso8601String(),
        'quantity':    _quantityCtrl.text.trim(),
        'unit':        _unit,
        'notes':       _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      };

      if (_unit == 'bags' &&
          _unitWeightCtrl.text.trim().isNotEmpty) {
        data['unitWeight'] = _unitWeightCtrl.text.trim();
      }

      await ref
          .read(yieldsRepositoryProvider)
          .createYield(data);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save harvest.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _calcKg() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final wt  = double.tryParse(_unitWeightCtrl.text) ?? 50;
    final kg  = qty * wt;
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(2)} t';
    }
    return '${kg.round()} kg';
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _unitWeightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(allCropsProvider);

    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: const Text('Record harvest',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Crop picker
            _label('Crop *'),
            cropsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error:   (_, __) =>
              const Text('Failed to load crops'),
              data: (crops) {
                final active = crops
                    .where((c) => c.status == 'Active')
                    .toList();
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14),
                  decoration: BoxDecoration(
                    color:        FarmioColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(
                        color: FarmioColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:      _cropFieldId,
                      hint:       const Text('Select crop'),
                      isExpanded: true,
                      items: active.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          '${c.cropTypeName} (${c.variety})'
                              ' — ${c.fieldName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (v) =>
                          setState(() => _cropFieldId = v),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Quantity + Unit
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Quantity *'),
                  _field(
                    controller: _quantityCtrl,
                    hint:       '10',
                    inputType:  TextInputType.number,
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Unit *'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    decoration: BoxDecoration(
                      color:        FarmioColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border:       Border.all(
                          color: FarmioColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value:      _unit,
                        isExpanded: true,
                        items: _units.map((u) =>
                            DropdownMenuItem(
                              value: u,
                              child: Text(u),
                            )).toList(),
                        onChanged: (v) =>
                            setState(() => _unit = v!),
                      ),
                    ),
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 16),

            // Unit weight (bags only)
            if (_unit == 'bags') ...[
              _label('Weight per bag (kg)'),
              _field(
                controller: _unitWeightCtrl,
                hint:       '50',
                inputType:  TextInputType.number,
              ),
              const SizedBox(height: 8),
              if (_quantityCtrl.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        FarmioColors.primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.scale_outlined,
                        size:  16,
                        color: FarmioColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '≈ ${_calcKg()} total weight',
                      style: const TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w700,
                        color:      FarmioColors.primary,
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 16),
            ],

            // Harvest date
            _label('Harvest date *'),
            InkWell(
              onTap:        _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color:        FarmioColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(
                      color: FarmioColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size:  16,
                      color: FarmioColors.textMuted),
                  const SizedBox(width: 10),
                  Text(Fmt.date(_harvestDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color:    FarmioColors.textPrimary,
                      )),
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
                hintText: 'Storage location, buyer name, etc...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: FarmioColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: FarmioColors.border),
                ),
                filled:    true,
                fillColor: FarmioColors.background,
              ),
            ),

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
                      color:       Colors.white,
                      strokeWidth: 2),
                )
                    : const Text('Save harvest'),
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) =>
      TextField(
        controller:   controller,
        keyboardType: inputType,
        onChanged:    (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: FarmioColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: FarmioColors.border),
          ),
          filled:    true,
          fillColor: FarmioColors.background,
        ),
      );
}
