import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
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

      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';

      if (!isInitialized) return null;

      if (!isInitialized) {
        return isSplash ? null : '/splash';
      }

      if (isAuthenticated) {
        if (isSplash || isLogin || isRegister) {
          return '/dashboard';
        }
        return null;
      }

      if (isLogin || isRegister) {
        return null;
      }

      return '/login';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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