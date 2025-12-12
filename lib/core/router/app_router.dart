import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/reset_password_screen.dart';
import '../../features/auth/views/otp_verification_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/dashboard_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;
      final isEmailVerified = authState.isEmailVerified ?? false;

      final loc = state.matchedLocation;

      final isSplash = loc == '/splash';
      final isLogin = loc == '/login';
      final isRegister = loc == '/register';
      final isForgot = loc == '/forgot-password';
      final isOtp = loc == '/request-otp';
      final isReset = loc == '/reset-password';

      // APP IS STILL LOADING
      if (!isInitialized) {
        return isSplash ? null : '/splash';
      }

      // If user is logged in but NOT verified → force logout and show login
      // (User must click verify link from email)
      if (isAuthenticated && !isEmailVerified) {
        return '/login';
      }

      // AUTHENTICATED + VERIFIED
      if (isAuthenticated && isEmailVerified) {
        if (isSplash || isLogin || isRegister || isForgot || isOtp || isReset) {
          return '/dashboard';
        }
        return null;
      }

      // NOT AUTHENTICATED
      if (!isAuthenticated) {
        if (isLogin || isRegister || isForgot || isOtp || isReset) {
          return null;
        }
        return '/login';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/request-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),

      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});