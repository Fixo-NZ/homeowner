import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authVM = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => context.go('/forgot-password'),
        ),
      ),
      body: Stack(
        children: [
          // Background waves
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
                              Image.asset("assets/images/fixo.png", width: 100, height: 96),
                              const SizedBox(height: AppDimensions.spacing16),

                              Text(
                                'Reset Password',
                                style: AppTextStyles.displaySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacing8),

                              Text(
                                "Enter your new password for\n${widget.email}",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacing24),

                              // NEW PASSWORD
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                decoration: InputDecoration(
                                  labelText: "New Password",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  errorText: authState.fieldErrors?['new_password']?.first,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureNew
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(() {
                                      _obscureNew = !_obscureNew;
                                    }),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacing16),

                              // CONFIRM PASSWORD
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                decoration: InputDecoration(
                                  labelText: "Confirm Password",
                                  prefixIcon: const Icon(Icons.lock_reset),
                                  errorText:
                                      authState.fieldErrors?['new_password_confirmation']?.first,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirm
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    }),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != _newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacing24),

                              // RESET BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            authVM.clearError();

                                            final success = await authVM.resetPassword(
                                              email: widget.email,
                                              newPassword: _newPasswordController.text.trim(),
                                              confirmNewPassword: _confirmPasswordController.text.trim(),
                                            );

                                            if (!mounted) return;

                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("Password reset successfully."),
                                                ),
                                              );

                                              context.go('/login');
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    authState.error ??
                                                        "Failed to reset password. Try again.",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  child: authState.isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text("Reset Password"),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.spacing24),
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