import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_brand_mark.dart';
import '../../core/theme/app_spacing.dart';

/// There is no mobile password-reset endpoint yet — reset your password on
/// the web app instead. This just points there rather than presenting a
/// form that would 404.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final host = Uri.parse(apiBaseUrl).host;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandMark(size: 64, radius: 18),
              const SizedBox(height: 20),
              Text(
                'Reset your password on the web',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use the "Forgot password?" link at $host, then come back here and sign in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: context.colors.textMuted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
                  child: const Text('Back to sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
