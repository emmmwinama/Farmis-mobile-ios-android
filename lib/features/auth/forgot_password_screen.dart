import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/account_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_brand_mark.dart';
import '../../shared/widgets/farmio_error_banner.dart';

enum _Stage { requestCode, resetPassword, done }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  _Stage _stage = _Stage.requestCode;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(accountRepositoryProvider).requestPasswordReset(email);
      if (mounted) setState(() => _stage = _Stage.resetPassword);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e, fallback: 'Could not send a reset code. Please try again.'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code we emailed you.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(accountRepositoryProvider).resetPassword(
            email: _emailCtrl.text.trim(),
            code: code,
            newPassword: password,
          );
      if (mounted) setState(() => _stage = _Stage.done);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e, fallback: 'Could not reset your password. Please try again.'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Center(child: BrandMark(size: 64, radius: 18)),
              const SizedBox(height: 20),
              ..._stageContent(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _stageContent(BuildContext context) {
    switch (_stage) {
      case _Stage.requestCode:
        return [
          Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            "Enter your account's email and we'll send you a reset code.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.colors.textMuted),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _requestCode(),
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            FarmioErrorBanner(message: _error!),
          ],
          const SizedBox(height: 22),
          _primaryButton('Send reset code', _requestCode),
        ];

      case _Stage.resetPassword:
        return [
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the code we sent to ${_emailCtrl.text.trim()} and choose a new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.colors.textMuted),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Reset code', prefixIcon: Icon(Icons.pin_outlined)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _resetPassword(),
            decoration: InputDecoration(
              labelText: 'New password',
              helperText: 'At least 8 characters',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            FarmioErrorBanner(message: _error!),
          ],
          const SizedBox(height: 22),
          _primaryButton('Reset password', _resetPassword),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _loading ? null : _requestCode,
              child: const Text("Didn't get a code? Resend"),
            ),
          ),
        ];

      case _Stage.done:
        return [
          Icon(Icons.check_circle_outline, size: 56, color: FarmioColors.success),
          const SizedBox(height: 16),
          Text(
            'Password updated',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.colors.textMuted),
          ),
          const SizedBox(height: 28),
          _primaryButton('Back to sign in', () => context.go('/login')),
        ];
    }
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
