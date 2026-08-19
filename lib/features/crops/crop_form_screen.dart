import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';
import '../fields/fields_provider.dart';
import 'crops_provider.dart';

class CropFormScreen extends ConsumerStatefulWidget {
  const CropFormScreen({super.key});

  @override
  ConsumerState<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends ConsumerState<CropFormScreen> {
  final _varietyCtrl = TextEditingController();
  final _areaCtrl    = TextEditingController();
  final _seasonCtrl  = TextEditingController();

  String?   _fieldId;
  String?   _cropTypeId;
  DateTime  _plantingDate        = DateTime.now();
  DateTime  _expectedHarvestDate =
  DateTime.now().add(const Duration(days: 120));
  bool      _saving = false;
  String?   _error;

  // Quick add crop type
  final _newTypeCtrl = TextEditingController();
  bool  _addingType  = false;

  Future<void> _save() async {
    if (_fieldId == null || _cropTypeId == null ||
        _varietyCtrl.text.trim().isEmpty ||
        _areaCtrl.text.trim().isEmpty ||
        _seasonCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all required fields.');
      return;
    }

    setState(() { _saving = true; _error = null; });

    try {
      await ref.read(cropsRepositoryProvider).createCrop({
        'fieldId':             _fieldId,
        'cropTypeId':          _cropTypeId,
        'variety':             _varietyCtrl.text.trim(),
        'areaPlanted':         _areaCtrl.text.trim(),
        'season':              _seasonCtrl.text.trim(),
        'plantingDate':        _plantingDate.toIso8601String(),
        'expectedHarvestDate': _expectedHarvestDate.toIso8601String(),
      });
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Failed to save crop: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate(bool isPlanting) async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: isPlanting ? _plantingDate : _expectedHarvestDate,
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isPlanting) {
          _plantingDate = picked;
        } else {
          _expectedHarvestDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _varietyCtrl.dispose();
    _areaCtrl.dispose();
    _seasonCtrl.dispose();
    _newTypeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields     = ref.watch(fieldsProvider);
    final cropTypes  = ref.watch(cropTypesProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Add crop',
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
              error:   (_, __) => const Text('Failed to load fields'),
              data:    (list) => DropdownButtonFormField<String>(
                initialValue: _fieldId,
                hint:        const Text('Select field'),
                isExpanded:  true,
                items: list.map((f) => DropdownMenuItem(
                  value: f.id,
                  child: Text(
                      '${f.name} (${f.availableArea.toStringAsFixed(2)} ha free)'),
                )).toList(),
                onChanged: (v) => setState(() => _fieldId = v),
              ),
            ),
            const SizedBox(height: 16),

            // Crop type picker
            _label('Crop type *'),
            cropTypes.when(
              loading: () => const LinearProgressIndicator(),
              error:   (_, __) => const Text('Failed to load crop types'),
              data:    (types) => Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _cropTypeId,
                    hint:       const Text('Select crop type'),
                    isExpanded: true,
                    items: types.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.name),
                    )).toList(),
                    onChanged: (v) =>
                        setState(() => _cropTypeId = v),
                  ),
                  const SizedBox(height: 8),

                  // Quick add type
                  if (_addingType)
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller:  _newTypeCtrl,
                          autofocus:   true,
                          decoration: const InputDecoration(
                            hintText:  'New crop type name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = _newTypeCtrl.text.trim();
                          if (name.isEmpty) return;
                          final type = await ref
                              .read(cropsRepositoryProvider)
                              .createCropType(name);
                          ref.invalidate(cropTypesProvider);
                          setState(() {
                            _cropTypeId = type.id;
                            _addingType = false;
                            _newTypeCtrl.clear();
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ])
                  else
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _addingType = true),
                      icon:  const Icon(Icons.add, size: 16),
                      label: const Text('Add new crop type'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Variety
            _label('Variety *'),
            _field(controller: _varietyCtrl, hint: 'e.g. SC403, Chitedze'),
            const SizedBox(height: 16),

            // Area + Season
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Area (ha) *'),
                  _field(
                    controller: _areaCtrl,
                    hint:       '1.5',
                    inputType:  TextInputType.number,
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Season *'),
                  _field(
                    controller: _seasonCtrl,
                    hint:       '2024/25',
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 16),

            // Dates
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Planting date *'),
                  _DateButton(
                    date:    _plantingDate,
                    onTap:   () => _pickDate(true),
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Expected harvest *'),
                  _DateButton(
                    date:  _expectedHarvestDate,
                    onTap: () => _pickDate(false),
                  ),
                ],
              )),
            ]),

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
                    width:  20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Save crop'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: FarmioColors.textMuted,
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
        decoration:   InputDecoration(hintText: hint),
      );
}

class _DateButton extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateButton({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color:        FarmioColors.background,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: FarmioColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 14, color: FarmioColors.textMuted),
          const SizedBox(width: 8),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: const TextStyle(
              fontSize: 13, color: FarmioColors.textPrimary,
            ),
          ),
        ]),
      ),
    );
  }
}