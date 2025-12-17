import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = ref.read(authViewModelProvider.notifier);
    authVM.clearError();

    final email = _emailController.text.trim();
    print('ForgotPasswordScreen: sending reset request for $email');

    final success = await authVM.requestPasswordReset(email);
    print('ForgotPasswordScreen: requestPasswordReset returned $success');

    if (!mounted) return;

    if (success) {
      print('ForgotPasswordScreen: mounted=$mounted');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening OTP screen...')),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          print('ForgotPasswordScreen: not mounted at post-frame, aborting navigation');
          return;
        }

        try {
          print('ForgotPasswordScreen: post-frame navigating to OTP for $email');
          context.push('/request-otp?email=${Uri.encodeComponent(email)}');

          ref.read(authViewModelProvider.notifier).acknowledgePasswordResetRequestHandled();
          print('ForgotPasswordScreen: navigation attempted (push) (post-frame)');
        } catch (e, s) {
          print('ForgotPasswordScreen: post-frame navigation error: $e\n$s');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation error: $e')),
            );
          }
        }
      });
    } else {
      final error = ref.read(authViewModelProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } 

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

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
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
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
                              const SizedBox(height: AppDimensions.spacing8),
                              Text(
                                'Enter your email to reset your password',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacing24),

                              // EMAIL FIELD
                              TextFormField(
                                controller: _emailController,
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
                              const SizedBox(height: AppDimensions.spacing24),

                              //SEND OTP BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handlePasswordReset,
                                  child: authState.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text('Send OTP'),
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