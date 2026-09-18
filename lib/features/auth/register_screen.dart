import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_brand_mark.dart';
import '../../core/theme/app_spacing.dart';

/// There is no mobile registration endpoint — a farm account is created on
/// the web app, then this app signs in to it. This screen just points new
/// users there instead of presenting a form that would 404.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final host = Uri.parse(apiBaseUrl).host;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandMark(size: 64, radius: 18),
              const SizedBox(height: 20),
              Text(
                'Create your account on the web',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign up for a farm at $host, then come back here and sign in.',
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
