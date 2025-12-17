import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeowner/features/auth/views/dashboard/profile.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/reset_password_screen.dart';
import '../../features/auth/views/otp_verification_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/dashboard_screen.dart';
import '../../features/auth/views/dashboard/home.dart';
import '../../features/auth/views/dashboard/profile.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

// Navigator key for the ShellRoute so nested navigation works correctly.
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;
      final isEmailVerified = authState.isEmailVerified ?? false;

      final loc = state.matchedLocation;

      // Debug: log router redirect inputs
      print('Router redirect check -> loc=$loc isInitialized=$isInitialized isAuthenticated=$isAuthenticated isEmailVerified=$isEmailVerified');

      final isSplash = loc == '/splash';
      final isLogin = loc == '/login';
      final isRegister = loc == '/register';
      final isForgot = loc == '/forgot-password';
      final isOtp = loc == '/request-otp';
      final isReset = loc == '/reset-password';

      // APP IS STILL LOADING
      if (!isInitialized) {
        final decision = isSplash ? 'allow' : 'redirect:/splash';
        print('Router decision (not initialized): $decision');
        return isSplash ? null : '/splash';
      }

      // If user is logged in but NOT verified → usually force logout and show login
      // (User must click verify link from email). However, allow the OTP
      // verification route so users who are in the password-reset flow can
      // still reach the OTP screen even if a token is present but email isn't verified.
      if (isAuthenticated && !isEmailVerified) {
        if (isOtp) {
          print('Router decision: authenticated but not verified; allowing OTP route');
          return null;
        }
        print('Router decision: authenticated but not verified; redirecting to /login');
        return '/login';
      }

      // AUTHENTICATED + VERIFIED
      if (isAuthenticated && isEmailVerified) {
        if (isSplash || isLogin || isRegister || isForgot || isOtp || isReset) {
          print('Router decision: authenticated+verified, redirecting to /dashboard');
          return '/dashboard';
        }
        print('Router decision: authenticated+verified, allow current route');
        return null;
      }

      // NOT AUTHENTICATED
      if (!isAuthenticated) {
        if (isLogin || isRegister || isForgot || isOtp || isReset) {
          print('Router decision: not authenticated, allowing public auth routes');
          return null;
        }
        print('Router decision: not authenticated, redirecting to /login');
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
      // SHELL ROUTE for the Dashboard with persistent navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // The DashboardScreen now acts as the container for the bottom nav bar
          return DashboardScreen(child: child); 
        },
        routes: [
          // 0. HOME TAB (Default Dashboard route)
          GoRoute(
            path: '/dashboard', // Base path (can be entered by redirect)
            redirect: (_, __) => '/dashboard/home', // Redirects to the first tab
          ),
          GoRoute(
            path: '/dashboard/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: const DashboardHomeView(), // The view with the new UI content
            ),
          ),
          // 1. JOBS TAB
          GoRoute(
            path: '/dashboard/jobs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: const Center(child: const Text('Jobs Screen')),
            ),
          ),
          // 2. MESSAGES TAB
          GoRoute(
            path: '/dashboard/messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: const Center(child: const Text('Messages Screen')),
            ),
          ),
          // 3. PROFILE / LOGOUT TAB (Treated as a screen for routing)
          GoRoute(
            path: '/dashboard/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: const ProfileScreen(),
            ),
          ),
          // 4. POST TAB (Floating Button)
          GoRoute(
            path: '/dashboard/post',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: const Center(child: const Text('Post/Create Screen')),
            ),
          ),
        ],
      ),
    ],
  );
});