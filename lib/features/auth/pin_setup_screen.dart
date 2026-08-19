import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/pin_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_brand_mark.dart';
import 'pin_pad.dart';

enum _Stage { choose, confirm }

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  _Stage _stage = _Stage.choose;
  String _firstPin = '';
  String _entered = '';
  String? _error;
  bool _saving = false;

  void _onDigit(String digit) {
    if (_entered.length >= kPinLength || _saving) return;
    setState(() {
      _error = null;
      _entered += digit;
    });
    if (_entered.length == kPinLength) {
      _onPinComplete();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty || _saving) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _onPinComplete() async {
    if (_stage == _Stage.choose) {
      setState(() {
        _firstPin = _entered;
        _entered = '';
        _stage = _Stage.confirm;
      });
      return;
    }

    if (_entered != _firstPin) {
      setState(() {
        _error = "PINs didn't match. Try again.";
        _entered = '';
        _firstPin = '';
        _stage = _Stage.choose;
      });
      return;
    }

    setState(() => _saving = true);
    await ref.read(pinProvider.notifier).setPin(_entered);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final title = _stage == _Stage.choose ? 'Create a PIN' : 'Confirm your PIN';
    final subtitle = _stage == _Stage.choose
        ? 'Choose a $kPinLength-digit PIN to protect this app.'
        : 'Enter the same PIN again to confirm.';

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
              Text(title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: FarmioColors.textPrimary,
                  )),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
              if (_saving)
                const CircularProgressIndicator()
              else
                PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
