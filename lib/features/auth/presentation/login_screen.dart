import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final ok = await context.read<AuthCubit>().login(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go('/dashboard');
    } else {
      final error = context.read<AuthCubit>().state.errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthCubit cubit) => cubit.state.isBusy);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 740;
    final cardPadding = compact ? 18.0 : 24.0;
    final topGap = compact ? 6.0 : 8.0;
    final sectionGap = compact ? 10.0 : 12.0;
    final formGap = compact ? 10.0 : 12.0;
    final actionGap = compact ? 12.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6FFFA), Color(0xFFF0F9FF), Color(0xFFEFF6FF)],
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.94, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Welcome Back',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          SizedBox(height: topGap),
                          Text(
                            'Private UPSC study workspace. Login to continue.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: sectionGap),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Email is required';
                              }
                              if (!text.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: formGap),
                          TextFormField(
                            controller: _password,
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed:
                                    () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: actionGap),
                          FilledButton(
                            onPressed: busy ? null : _login,
                            child:
                                busy
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Login'),
                          ),
                          SizedBox(height: topGap),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton(
                                onPressed:
                                    busy ? null : () => context.push('/signup'),
                                child: const Text(
                                  "Don't have an account? Create one",
                                ),
                              ),
                            ],
                          ),
                          if (compact) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Tip: You can sign up in under 30 seconds.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
