import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('forgotPassword')),
        leading: IconButton(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
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
                  Text(l10n.t('resetInfo')),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.t('email'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return l10n.t('requiredField');
                      if (!email.contains('@')) return l10n.t('invalidEmail');
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
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: auth.isLoading ? null : _submit,
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: Text(l10n.t('sendReset')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(_emailController.text.trim());
    if (ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('saved'))));
      context.go('/login');
    }
  }
}
