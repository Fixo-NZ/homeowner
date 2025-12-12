import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Wavy background
          Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset('assets/images/Ellipse 1.png', fit: BoxFit.cover, width: double.infinity),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset('assets/images/Ellipse 2.png', fit: BoxFit.cover, width: double.infinity),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset('assets/images/Ellipse 3.png', fit: BoxFit.cover, width: double.infinity),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo / Title
                              Image.asset("assets/images/fixo.png", width: 100, height: 96),
                              const SizedBox(height: AppDimensions.spacing16),
                              Text(
                                'Login',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacing8),
                              Text(
                                'Enter your account to get started',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Email field
                              TextFormField(
                                controller: _identifierController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  errorText: authState.fieldErrors?['email']?.first,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  errorText: authState.fieldErrors?['password']?.first,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacing24),

                              // Forgot password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      context.go('/forgot-password');
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.onSecondary,
                                      overlayColor: AppColors.onSecondary.withOpacity(0.1),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: AppColors.onSecondary,
                                        decorationColor: AppColors.onSecondary,
                                        decorationThickness: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Login button
                              SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authState.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      authViewModel.clearError();
                                      final isSuccess = await authViewModel.login(
                                        _identifierController.text.trim(),
                                        _passwordController.text,
                                      );
                                      if (!mounted) return;

                                      if (isSuccess) {
                                        context.go('/dashboard');
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              authState.error ?? 'Login failed. Please check your credentials.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                child: authState.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Login'),
                              ),
                            ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // Register link
                              TextButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.onSecondary,
                                  overlayColor: AppColors.onSecondary.withOpacity(0.1),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: AppColors.onSecondary),
                                    children: [
                                      TextSpan(
                                        text: "Register",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.onSecondary,
                                          decorationThickness: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}