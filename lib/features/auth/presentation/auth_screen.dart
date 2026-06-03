import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import 'auth_controller.dart';

enum AuthMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({required this.mode, super.key});

  final AuthMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'demo@foodhub.app');
  final _passwordController = TextEditingController(text: 'demo123');

  bool get _isRegister => widget.mode == AuthMode.register;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.t('appName'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      l10n.t('welcome'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    if (_isRegister) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.t('name'),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) => _required(value, l10n),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.t('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return l10n.t('requiredField');
                        if (!email.contains('@')) return l10n.t('invalidEmail');
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.t('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return l10n.t('shortPassword');
                        }
                        return null;
                      },
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: auth.isLoading ? null : _submit,
                      icon: auth.isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isRegister ? Icons.person_add_alt : Icons.login,
                            ),
                      label: Text(
                        _isRegister ? l10n.t('createAccount') : l10n.t('login'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.go(_isRegister ? '/login' : '/register');
                      },
                      child: Text(
                        _isRegister
                            ? l10n.t('alreadyAccount')
                            : l10n.t('needAccount'),
                      ),
                    ),
                    if (!_isRegister)
                      TextButton(
                        onPressed: () => context.go('/forgot'),
                        child: Text(l10n.t('forgotPassword')),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value, AppLocalizations l10n) {
    if ((value ?? '').trim().isEmpty) {
      return l10n.t('requiredField');
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = ref.read(authControllerProvider.notifier);
    final success = _isRegister
        ? await controller.signUp(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          )
        : await controller.signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    if (success && mounted) {
      context.go('/');
    }
  }
}
