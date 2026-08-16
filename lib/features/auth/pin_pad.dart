import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

const int kPinLength = 4;

/// Row of filled/empty dots showing how many PIN digits have been entered.
class PinDots extends StatelessWidget {
  final int entered;
  const PinDots({super.key, required this.entered});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < kPinLength; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < entered
                  ? FarmioColors.primary
                  : Colors.transparent,
              border: Border.all(
                color: i < entered
                    ? FarmioColors.primary
                    : FarmioColors.border,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

/// 3x4 numeric keypad (1-9, blank, 0, backspace) used by both the PIN
/// setup and unlock screens.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final digit in row) ...[
                  _KeypadButton(label: digit, onTap: () => onDigit(digit)),
                  const SizedBox(width: 18),
                ],
              ]..removeLast(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 64),
            const SizedBox(width: 18),
            _KeypadButton(label: '0', onTap: () => onDigit('0')),
            const SizedBox(width: 18),
            _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeypadButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FarmioColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: label != null
                ? Text(label!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: FarmioColors.textPrimary,
                    ))
                : Icon(icon, color: FarmioColors.textSecond),
          ),
        ),
      ),
    );
  }
}
