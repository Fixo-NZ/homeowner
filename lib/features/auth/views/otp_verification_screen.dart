import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email; 

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = ref.read(authViewModelProvider.notifier);
    authVM.clearError();

    final success = await authVM.verifyOtp(
      email: widget.email,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // SUCCESS: Always navigate to ResetPasswordScreen for this flow
      context.go('/reset-password?email=${Uri.encodeComponent(widget.email)}');
    } else {
      final authState = ref.read(authViewModelProvider);
      if (mounted && authState.error != null) {
        // FAILURE: Show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleResendOtp() async {
    final authVM = ref.read(authViewModelProvider.notifier);
    
    // Always request password reset for resend in this context
    await authVM.requestPasswordReset(widget.email); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New OTP sent! Please check your email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Simplified text since it's only for password reset
    const String titleText = "Reset Password Verification";
    const String instructionText = "Enter the OTP sent to your email to reset your password.";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          // Back arrow always goes to forgot-password screen
          onPressed: () => context.go('/forgot-password'),
        ),
      ),
      // ... (rest of the UI code is unchanged)
      body: Stack(
        children: [
          // Wavy background (omitted for brevity)
          // ...

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset("assets/images/fixo.png",
                                  width: 100, height: 96),
                              const SizedBox(height: AppDimensions.spacing16),
                              
                              // Title
                              Text(
                                titleText,
                                style: AppTextStyles.titleLarge
                                    .copyWith(color: AppColors.onSurface),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacing8),

                              Text(
                                '$instructionText\n${widget.email}',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: AppDimensions.spacing24),

                              // OTP FIELD
                              TextFormField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'OTP Code',
                                  prefixIcon: const Icon(Icons.password_outlined),
                                  errorText:
                                      authState.fieldErrors?['otp']?.first,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your OTP';
                                  }
                                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                                    return 'OTP must be 6 digits';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppDimensions.spacing24),

                              // VERIFY BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handleVerifyOtp,
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Verify OTP'),
                                ),
                              ),

                              const SizedBox(height: AppDimensions.spacing16),

                              // Resend OTP
                              TextButton(
                                onPressed: authState.isLoading ? null : _handleResendOtp,
                                child: const Text('Resend OTP'),
                              ),

                              const SizedBox(height: AppDimensions.spacing16),
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