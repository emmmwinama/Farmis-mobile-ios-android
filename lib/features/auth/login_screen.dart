import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/farmio_error_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _loading      = false;
  bool  _obscure      = true;
  String? _error;

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      setState(() =>
      _error = 'Please enter your email and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) context.go('/dashboard');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String?;
      setState(() =>
      _error = msg ?? 'Invalid credentials. Try again.');
    } catch (_) {
      setState(() =>
      _error = 'Connection error. Check your network.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmioColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        FarmioColors.primaryDark,
                        FarmioColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:      FarmioColors.primary
                            .withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset:     const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text('AgriVault',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   32,
                    fontWeight: FontWeight.w800,
                    color:      FarmioColors.textPrimary,
                    letterSpacing: -1,
                  )),
              const SizedBox(height: 6),
              const Text('Offline-first farm operations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color:    FarmioColors.textMuted,
                  )),
              const SizedBox(height: 48),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border:       Border.all(
                      color: FarmioColors.border),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black
                          .withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset:     const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text('Sign in to your account',
                        style: TextStyle(
                          fontSize:   18,
                          fontWeight: FontWeight.w800,
                          color:      FarmioColors.textPrimary,
                        )),
                    const SizedBox(height: 4),
                    const Text(
                        'Sign in with your Farmis/Farmio account',
                        style: TextStyle(
                          fontSize: 13,
                          color:    FarmioColors.textMuted,
                        )),
                    const SizedBox(height: 24),

                    // Email
                    _FieldLabel(label: 'Email address'),
                    const SizedBox(height: 6),
                    TextField(
                      controller:      _emailCtrl,
                      keyboardType:    TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText:   'you@example.com',
                        prefixIcon: Icon(
                            Icons.email_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _FieldLabel(label: 'Password'),
                    const SizedBox(height: 6),
                    TextField(
                      controller:      _passwordCtrl,
                      obscureText:     _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted:     (_) => _login(),
                      decoration: InputDecoration(
                        hintText:   '••••••••',
                        prefixIcon: const Icon(
                            Icons.lock_outline, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () => setState(
                                  () => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      FarmioErrorBanner(message: _error!),
                    ],

                    const SizedBox(height: 20),

                    // Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          FarmioColors.primary,
                          disabledBackgroundColor:
                          FarmioColors.primaryLight,
                        ),
                        child: _loading
                            ? const SizedBox(
                            width:  20, height: 20,
                            child: CircularProgressIndicator(
                              color:       Colors.white,
                              strokeWidth: 2.5,
                            ))
                            : const Text('Sign in',
                            style: TextStyle(
                              fontSize:   15,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'AgriVault ${DateTime.now().year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color:    FarmioColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color:      FarmioColors.textSecond,
        ));
  }
}
