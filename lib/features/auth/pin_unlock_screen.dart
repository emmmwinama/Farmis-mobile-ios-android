import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/pin_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_brand_mark.dart';
import 'pin_pad.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  String _entered = '';
  String? _error;
  bool _checking = false;

  void _onDigit(String digit) {
    if (_entered.length >= kPinLength || _checking) return;
    setState(() {
      _error = null;
      _entered += digit;
    });
    if (_entered.length == kPinLength) {
      _onPinComplete();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty || _checking) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _onPinComplete() async {
    setState(() => _checking = true);
    final ok = await ref.read(pinProvider.notifier).unlock(_entered);
    if (!mounted) return;
    if (ok) {
      context.go('/dashboard');
      return;
    }
    setState(() {
      _checking = false;
      _entered = '';
      _error = 'Incorrect PIN. Try again.';
    });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset PIN?'),
        content: const Text(
            "You'll be asked to set a new PIN. Your farm data is not affected."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset',
                style: TextStyle(color: FarmioColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(pinProvider.notifier).resetPin();
      if (mounted) context.go('/pin-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const BrandMark(size: 72, radius: 20),
              const SizedBox(height: 24),
              const Text('Enter your PIN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: FarmioColors.textPrimary,
                  )),
              const SizedBox(height: 6),
              const Text('AgriVault',
                  style: TextStyle(
                    fontSize: 14,
                    color: FarmioColors.textMuted,
                  )),
              const SizedBox(height: 32),
              PinDots(entered: _entered.length),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(
                      color: FarmioColors.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    )),
              ],
              const Spacer(),
              if (_checking)
                const CircularProgressIndicator()
              else
                PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _confirmReset,
                child: const Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
