import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../provider/auth_provider.dart';

class SignInPage extends StatefulWidget {
  /// Where to go after signing in, e.g. `/checkout`.
  final String? redirect;

  const SignInPage({super.key, this.redirect});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Public DummyJSON test account.
  static const _demoUsername = 'emilys';
  static const _demoPassword = 'emilyspass';

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _useDemoAccount() {
    _usernameController.text = _demoUsername;
    _passwordController.text = _demoPassword;
    context.read<AuthProvider>().clearError();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );
    if (!success || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, ${auth.user?.firstName ?? 'back'}!')),
    );

    final redirect = widget.redirect;
    if (redirect != null && redirect.startsWith('/')) {
      context.pushReplacement(redirect);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to ${AppStrings.appName}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.redirect == AppRouter.checkout
                          ? 'Sign in to complete your order.'
                          : 'Sign in to check out and see your orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (auth.errorMessage != null) ...[
                      _ErrorBanner(message: auth.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          Validators.required(value, field: 'Username'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (value) =>
                          Validators.required(value, field: 'Password'),
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      label: 'Sign in',
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 20),
                    _DemoAccountCard(
                      username: _demoUsername,
                      password: _demoPassword,
                      onUse: _useDemoAccount,
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
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountCard extends StatelessWidget {
  final String username;
  final String password;
  final VoidCallback onUse;

  const _DemoAccountCard({
    required this.username,
    required this.password,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.science_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demo account',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '$username / $password',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onUse, child: const Text('Use')),
          ],
        ),
      ),
    );
  }
}
