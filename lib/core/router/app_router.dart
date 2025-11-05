import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/job_posting/views/job_post_success_sccreen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/dashboard_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/job_posting/views/category_screen.dart';
import '../../features/job_posting/views/service_selection_screen.dart';
import '../../features/job_posting/views/job_post_form_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
 
 // final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/job', // Change this to start with category screen
    /* redirect: (context, state) {
     
      
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }


      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/dashboard';
      }
      

      return null;
    }, */
    routes: [
      
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

      // Job Posting Routes (nested under job)
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
    ],
  );
});