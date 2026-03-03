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
  bool _obscurePassword = true;

  static const _primary = Color(0xFF1A227F);
  static const _lightBg = Color(0xFFF6F6F8);
  static const _darkBg = Color(0xFF121320);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() != true) return;

    final errorMessage = await context.read<AuthCubit>().signup(
      name: _name.text,
      identifier: _email.text,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final fieldFill = isDark ? const Color(0x33121320) : Colors.white;
    final fieldBorder = BorderSide(color: _primary.withValues(alpha: 0.2));

    return Scaffold(
      backgroundColor: isDark ? _darkBg : _lightBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: textPrimary,
                              ),
                              onPressed: busy ? null : context.pop,
                            ),
                            Expanded(
                              child: Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Join UPSC Journey',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Empowering your civil services preparation with precision and focus.',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildLabel('Full Name', textPrimary),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: 'Enter your full name',
                            icon: Icons.person,
                            fillColor: fieldFill,
                            borderSide: fieldBorder,
                          ),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Please enter full name'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Email or Phone', textPrimary),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _email,
                          decoration: _inputDecoration(
                            hint: 'Enter email or mobile number',
                            icon: Icons.mail_outline,
                            fillColor: fieldFill,
                            borderSide: fieldBorder,
                          ),
                          validator: (value) =>
                              (value?.trim().isEmpty ?? true)
                                  ? 'Please enter email or phone'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Password', textPrimary),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            hint: 'Create a strong password',
                            icon: Icons.lock_outline,
                            fillColor: fieldFill,
                            borderSide: fieldBorder,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) => (value ?? '').length < 6
                              ? 'Minimum 6 characters'
                              : null,
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 6,
                            ),
                            onPressed: busy ? null : _signup,
                            child: busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            'By signing up, you agree to our Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: textPrimary),
                            ),
                            GestureDetector(
                              onTap: busy ? null : () => context.go('/login'),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: color,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color fillColor,
    required BorderSide borderSide,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: fillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: borderSide,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
