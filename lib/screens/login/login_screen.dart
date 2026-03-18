import 'package:flutter/material.dart';

import '../register/register_screen.dart';
import 'widgets/brand_header.dart';
import 'widgets/divider_label.dart';
import 'widgets/field_heading.dart';
import 'widgets/primary_button.dart';
import 'widgets/social_button.dart';
import 'widgets/text_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF231237),
          content: Text('Welcome back, ${_emailController.text.trim()}'),
        ),
      );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF231237),
          content: Text(message),
        ),
      );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please enter your password.';
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  Route<void> _buildRegisterRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (_, animation, secondaryAnimation) => const RegisterScreen(),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF120B1F),
          gradient: RadialGradient(
            center: Alignment(0, -1.15),
            radius: 1.6,
            colors: [Color(0xFF211133), Color(0xFF120B1F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const BrandHeader(),
                      const SizedBox(height: 52),
                      const FieldHeading(text: 'Email Address'),
                      const SizedBox(height: 12),
                      TextInput(
                        controller: _emailController,
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.mail_rounded,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          const Expanded(child: FieldHeading(text: 'Password')),
                          GestureDetector(
                            onTap: () => _showMessage(
                              'Password recovery is not wired yet.',
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF7F2CFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextInput(
                        controller: _passwordController,
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onFieldSubmitted: (_) =>
                            _isSubmitting ? null : _handleLogin(),
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFFAAB1C4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 42),
                      PrimaryButton(
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _handleLogin,
                      ),
                      const SizedBox(height: 34),
                      const DividerLabel(),
                      const SizedBox(height: 34),
                      SocialButton(
                        label: 'Google',
                        onPressed: () => _showMessage(
                          'Google sign-in is ready for integration.',
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(_buildRegisterRoute());
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF9098AB),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF7F2CFF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
