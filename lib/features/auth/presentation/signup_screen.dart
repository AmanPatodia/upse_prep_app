import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/auth_cubit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() != true) return;

    final errorMessage = await context.read<AuthCubit>().signup(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signup successful. Please login with your credentials.'),
      ),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthCubit cubit) => cubit.state.isBusy);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 760;
    final padding = compact ? 18.0 : 24.0;
    final gap = compact ? 10.0 : 12.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFBEB), Color(0xFFEFF6FF)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Create your private UPSC account. Your credentials are stored locally in Hive.',
                        ),
                        SizedBox(height: compact ? 14 : 20),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if ((value?.trim() ?? '').isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: gap),
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
                        SizedBox(height: gap),
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
                        SizedBox(height: gap),
                        TextFormField(
                          controller: _confirmPassword,
                          obscureText: _hideConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              onPressed:
                                  () => setState(
                                    () =>
                                        _hideConfirmPassword =
                                            !_hideConfirmPassword,
                                  ),
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != _password.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        FilledButton.icon(
                          onPressed: busy ? null : _signup,
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label:
                              busy
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Create account'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: busy ? null : () => context.go('/login'),
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
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
