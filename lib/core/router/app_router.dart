import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/fetch_tradies/views/tradie_detail_screen.dart';
import 'package:tradie/features/fetch_tradies/views/tradie_list_screen.dart';
import 'package:tradie/features/urgentBooking/views/urgent_booking_screen.dart';
import 'package:tradie/features/urgentBooking/views/create_service_screen.dart';
import 'package:tradie/features/urgentBooking/views/service_detail_screen.dart';
import 'package:tradie/features/urgentBooking/views/tradie_recommendations_screen.dart';
import 'package:tradie/payment/views/payment_screen.dart';
import 'package:tradie/payment/views/account_setup_success_screen.dart';
import '../../paymentProcess/views/payment_screen.dart' as payment_process;
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/dashboard_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      // If not authenticated and not on login/register page, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // If authenticated and on login/register page, redirect to dashboard
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      //tradie_fetching
      GoRoute(
        path: '/services',
        builder: (context, state) => const TradieListScreen(),
      ),
      GoRoute(
        path: '/jobs/:jobId/recommend-tradies',
        builder: (context, state) {
          final jobId = int.tryParse(state.pathParameters['jobId'] ?? '') ?? 0;
          return TradieDetailScreen(jobId: jobId);
        },
      ),

      // urgent booking routes
      GoRoute(
        path: '/urgent-booking',
        builder: (context, state) => const UrgentBookingScreen(),
      ),
      GoRoute(
        path: '/urgent-booking/create',
        builder: (context, state) => const CreateServiceScreen(),
      ),
      GoRoute(
        path: '/urgent-booking/service/:serviceId',
        builder: (context, state) {
          final serviceId = int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/urgent-booking/service/:serviceId/recommendations',
        builder: (context, state) {
          final serviceId = int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          return TradieRecommendationsScreen(serviceId: serviceId);
        },
        
      ),

      // payment route
      // dev/test payment route (temporary)

      GoRoute(
        path: '/payment/process',
        builder: (context, state) => const payment_process.PaymentScreen(),
      ),

      GoRoute(
        path: '/payment/success',
        builder: (context, state) => const AccountSetupSuccessScreen(),
      ),

      GoRoute(
        path: '/payment/:serviceId',
        builder: (context, state) {
          final serviceId = int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          final amount = double.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 0.0;
          return PaymentScreen(serviceId: serviceId, amount: amount);
        },
      ),
    ],
  );
});
