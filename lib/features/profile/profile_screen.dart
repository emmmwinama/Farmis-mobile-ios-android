import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/account_provider.dart';
import '../../core/auth/pin_provider.dart';
import '../../core/db/app_database.dart';
import '../../core/theme/app_theme.dart';
import 'account_sync_section.dart';
import 'farm_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(farmProfileProvider);
    ref.watch(accountHydrationProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Could not load the farm profile.'),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: FarmioColors.primary,
                    child: Text(
                      (_avatarSource(data)).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data?.ownerName?.isNotEmpty == true)
                          Text(
                            data!.ownerName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: FarmioColors.textMuted,
                            ),
                          ),
                        Text(
                          data?.name ?? 'My Farm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: FarmioColors.textPrimary,
                          ),
                        ),
                        Text(
                          data?.location ?? 'Location not set',
                          style: const TextStyle(
                            fontSize: 13,
                            color: FarmioColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit farm details',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditForm(context, ref, data),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AccountSyncSection(),
            const SizedBox(height: 16),
            _ProfileAction(
              icon: Icons.file_present_outlined,
              title: 'Record packs',
              subtitle: 'Prepare loan, buyer, audit and insurance evidence',
              onTap: () => context.push('/records'),
            ),
            const SizedBox(height: 12),
            _ProfileAction(
              icon: Icons.people_alt_outlined,
              title: 'Employees',
              subtitle: 'Manage payroll capacity and team evidence',
              onTap: () => context.push('/employees'),
            ),
            const SizedBox(height: 12),
            _ProfileAction(
              icon: Icons.fact_check_outlined,
              title: 'Seasonal templates',
              subtitle: 'Plan crop activities using proven workflows',
              onTap: () => context.push('/templates'),
            ),
            const SizedBox(height: 12),
            _ProfileAction(
              icon: Icons.download_outlined,
              title: 'Import existing data',
              subtitle: 'Bring in fields, crops and records from the old app',
              onTap: () => context.push('/import'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('Lock app'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FarmioColors.danger,
                ),
                onPressed: () => ref.read(pinProvider.notifier).lock(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _avatarSource(FarmProfileData? data) {
    if (data?.ownerName?.isNotEmpty == true) return data!.ownerName![0];
    if (data?.name.isNotEmpty == true) return data!.name[0];
    return 'F';
  }

  Future<void> _showEditForm(
    BuildContext context,
    WidgetRef ref,
    FarmProfileData? current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FarmProfileForm(current: current),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: FarmioColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: FarmioColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: FarmioColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: FarmioColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: FarmioColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _FarmProfileForm extends ConsumerStatefulWidget {
  final FarmProfileData? current;
  const _FarmProfileForm({required this.current});

  @override
  ConsumerState<_FarmProfileForm> createState() => _FarmProfileFormState();
}

class _FarmProfileFormState extends ConsumerState<_FarmProfileForm> {
  late final _ownerNameCtrl =
      TextEditingController(text: widget.current?.ownerName ?? '');
  late final _nameCtrl =
      TextEditingController(text: widget.current?.name ?? '');
  late final _locationCtrl =
      TextEditingController(text: widget.current?.location ?? '');
  late final _latCtrl = TextEditingController(
      text: widget.current?.locationLat?.toString() ?? '');
  late final _lngCtrl = TextEditingController(
      text: widget.current?.locationLng?.toString() ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Farm name and location are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(farmProfileRepositoryProvider).saveProfile(
            ownerName: _ownerNameCtrl.text.trim().isEmpty
                ? null
                : _ownerNameCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            location: _locationCtrl.text.trim(),
            locationLat: double.tryParse(_latCtrl.text.trim()),
            locationLng: double.tryParse(_lngCtrl.text.trim()),
          );
      ref.invalidate(farmProfileProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Could not save farm details: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Farm details',
                    style: TextStyle(
                      color: FarmioColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 16),
                TextField(
                  controller: _ownerNameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Your name (optional)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Farm name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    helperText: 'City or district, e.g. Zomba',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true, decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Latitude (optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lngCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true, decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Longitude (optional)'),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Latitude/longitude sharpen the weather forecast; otherwise the location name is used.',
                    style: TextStyle(
                        fontSize: 11, color: FarmioColors.textMuted),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: FarmioColors.danger)),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
