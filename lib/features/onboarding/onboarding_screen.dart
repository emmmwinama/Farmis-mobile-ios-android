import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/onboarding/onboarding_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_brand_mark.dart';
import '../profile/farm_profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _ownerNameCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _farmNameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_farmNameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
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
            name: _farmNameCtrl.text.trim(),
            location: _locationCtrl.text.trim(),
          );
      ref.invalidate(farmProfileProvider);
      ref.read(onboardingProvider.notifier).markComplete();
      if (mounted) context.go('/pin-setup');
    } catch (_) {
      setState(() => _error = 'Could not save your details. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: BrandMark(size: 72, radius: 20)),
              const SizedBox(height: 24),
              const Text(
                'Welcome to AgriVault',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FarmioColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Let's set up your farm before anything else. This stays on your device.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: FarmioColors.textMuted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _ownerNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Your name (optional)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _farmNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Farm name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  helperText: 'City or district, e.g. Zomba — used for weather',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FarmioColors.danger)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Get started'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You'll set a PIN next to lock the app.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: FarmioColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
