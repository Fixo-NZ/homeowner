import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    // Listen to auth state changes
      ref.listen<AuthState>(authViewModelProvider, (previous, next) {
        if (next.isRegistered) {
          final emailForVerification = next.pendingEmail ?? _emailController.text.trim();
          context.go('/email-verification?email=${Uri.encodeComponent(emailForVerification)}');
          ref.read(authViewModelProvider.notifier).acknowledgeRegistrationHandled();
        }

        if (next.error != null && next.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => context.go('/login'),
          ),
        ),
          body: Stack(
            children: [
              // Wavy background
              Positioned.fill(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset('assets/images/Ellipse 1.png',
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset('assets/images/Ellipse 2.png',
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset('assets/images/Ellipse 3.png',
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                  ],
                ),
              ),
            SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Image.asset("assets/images/fixo.png", width: 100, height: 96),
                    const SizedBox(height: AppDimensions.spacing16),
                    Text(
                      'Create Account',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      'Join our community',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: authState.fieldErrors?['first_name']?.first,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Middle Name (optional)
                    TextFormField(
                      controller: _middleNameController,
                      decoration: InputDecoration(
                        labelText: 'Middle Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: authState.fieldErrors?['middle_name']?.first,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name *',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: authState.fieldErrors?['last_name']?.first,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email *',
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

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone *',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        errorText: authState.fieldErrors?['phone']?.first,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
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
                        errorText: authState.fieldErrors?['password']?.first,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password *',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        errorText:
                            authState.fieldErrors?['password_confirmation']?.first,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Password do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing32),

                    // Register button
                    SizedBox(
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  authViewModel.clearError();
                                  await authViewModel.register(
                                    firstName: _firstNameController.text.trim(),
                                    middleName:
                                        _middleNameController.text.trim().isEmpty
                                        ? null
                                        : _middleNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                    passwordConfirmation:
                                        _confirmPasswordController.text,
                                    phone: _phoneController.text.trim(),
                                  );
                                }
                              },
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Login link
                    TextButton(
                      onPressed: () {
                        context.go('/login');
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
                          text: "Already have an account? ",
                          style: TextStyle(color: AppColors.onSecondary),
                          children: [
                            TextSpan(
                              text: "Login",
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
        ],
      ),
    );
  }
}
