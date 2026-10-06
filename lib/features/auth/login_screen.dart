import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    // Mock login delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo Placeholder
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Arun Invoice Pro',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineXl.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your invoices',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign In'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
