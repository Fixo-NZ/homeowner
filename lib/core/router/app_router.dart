import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/dashboard_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/job_posting/views/category_screen.dart';
import '../../features/job_posting/views/job_detail_screen.dart';
import '../../features/job_posting/views/job_edit_screen.dart';
import '../../features/job_posting/views/job_list_screen.dart';
import '../../features/job_posting/views/service_selection_screen.dart';
import '../../features/job_posting/views/job_post_form_screen.dart';
import '../../features/job_posting/views/job_post_success_sccreen.dart';

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

      if (!isInitialized) return null; // wait for auth initialization

      if (isAuthenticated) {
        if (isSplash || isLogin || isRegister) return '/dashboard';
        return null;
      }

      if (isLogin || isRegister) return null;

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
      GoRoute(
        path: '/job',
        builder: (context, state) => const CategoryScreen(),
        routes: [
          GoRoute(
            path: 'services',
            builder: (context, state) => const ServiceSelectionScreen(),
          ),
          GoRoute(
            path: 'form',
            builder: (context, state) => const JobPostFormScreen(),
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => const JobPostSuccessScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const JobListScreen(),
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return JobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: '/jobs/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return JobEditScreen(jobId: id);
        },
      ),
    ],
  );
});
