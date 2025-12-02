import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/booking_create_update_cancel/views/booking_details_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/cancellation_request_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/cancellation_success_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/job_in_progress_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/my_bookings_screen.dart';
import 'package:tradie/features/fetch_tradies/views/tradie_detail_screen.dart';
import 'package:tradie/features/fetch_tradies/views/tradie_list_screen.dart';
import 'package:tradie/features/urgentBooking/views/urgent_booking_screen.dart';
import 'package:tradie/features/urgentBooking/views/create_service_screen.dart';
import 'package:tradie/features/urgentBooking/views/service_detail_screen.dart';
import 'package:tradie/features/urgentBooking/views/tradie_recommendations_screen.dart';
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
          final serviceId =
              int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/urgent-booking/service/:serviceId/recommendations',
        builder: (context, state) {
          final serviceId =
              int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          return TradieRecommendationsScreen(serviceId: serviceId);
        },
      ),

      // booking create/update/cancel
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/bookings/:id',
        name: 'booking-details',
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['id']!);
          return BookingDetailsScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/bookings/:id/in-progress',
        name: 'job-in-progress',
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['id']!);
          return JobInProgressScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/bookings/:id/cancel',
        name: 'cancel-booking',
        builder: (context, state) {
          final bookingId = int.parse(state.pathParameters['id']!);
          return CancellationRequestScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/bookings/:id/cancel-success',
        name: 'cancel-success',
        builder: (context, state) {
          final referenceNumber = state.uri.queryParameters['ref'] ?? '';
          return CancellationSuccessScreen(referenceNumber: referenceNumber);
        },
      ),
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
