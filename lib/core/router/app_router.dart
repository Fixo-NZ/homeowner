import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/auth_otp/viewmodels/auth_viewmodel.dart';
import 'package:tradie/features/auth_otp/views/dashboard_screen.dart';
import 'package:tradie/features/auth_otp/views/login_screen.dart';
import 'package:tradie/features/auth_otp/views/register_screen.dart';
import 'package:tradie/features/auth_otp/views/otp_screen.dart';
import 'package:tradie/features/auth_otp/views/reset_password_screen.dart';

// TRADIES & BOOKINGS
import 'package:tradie/features/fetch_tradies/views/tradie_list_screen.dart';
import 'package:tradie/features/fetch_tradies/views/tradie_detail_screen.dart';
import 'package:tradie/features/urgentBooking/views/urgent_booking_screen.dart';
import 'package:tradie/features/urgentBooking/views/create_service_screen.dart';
import 'package:tradie/features/urgentBooking/views/service_detail_screen.dart';
import 'package:tradie/features/urgentBooking/views/tradie_recommendations_screen.dart';
import 'package:tradie/features/urgentBooking/views/booking_flow_screen.dart';
import 'package:tradie/features/urgentBooking/views/tradie_profile_screen.dart';
import 'package:tradie/features/urgentBooking/models/tradie_recommendation.dart';

import 'package:tradie/features/booking_create_update_cancel/views/my_bookings_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/booking_details_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/job_in_progress_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/cancellation_request_screen.dart';
import 'package:tradie/features/booking_create_update_cancel/views/cancellation_success_screen.dart';

/// ROUTER PROVIDER FOR RIVERPOD
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/login',

    /// 🔒 REDIRECT LOGIC
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;

      final loggingIn = state.matchedLocation == '/login';
      final registering = state.matchedLocation == '/register';
      final otp = state.matchedLocation == '/otp';
      final resetPw = state.matchedLocation == '/reset-password';

      // If NOT authenticated → allow only login/register/otp/reset
      if (!isAuth && !loggingIn && !registering && !otp && !resetPw) {
        return '/login';
      }

      // If authenticated → block login/register/otp/reset → go to dashboard
      if (isAuth && (loggingIn || registering || otp || resetPw)) {
        return '/dashboard';
      }

      return null;
    },

    /// ROUTES
    routes: [
      /// LOGIN
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      /// REGISTER (accepts phone number via state.extra)
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return RegisterScreen(phoneNumber: phoneNumber);
        },
      ),

      /// OTP SCREEN
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),

      /// RESET PASSWORD
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      /// DASHBOARD
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // ---------------------------------------------------------------------
      // TRADIES FETCHING
      // ---------------------------------------------------------------------
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

      // ---------------------------------------------------------------------
      // URGENT BOOKING
      // ---------------------------------------------------------------------
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

      GoRoute(
        path: '/urgent-booking/service/:serviceId/book/:tradieId',
        name: 'book-tradie',
        builder: (context, state) {
          final serviceId =
              int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          final tradieId =
              int.tryParse(state.pathParameters['tradieId'] ?? '') ?? 0;
          // Get tradie from extra or fetch it
          final tradie = state.extra as TradieRecommendation?;
          if (tradie != null) {
            return BookingFlowScreen(tradie: tradie, jobId: serviceId);
          }
          // If tradie not passed, we need to show error or fetch it
          return Scaffold(
            appBar: AppBar(title: const Text('Booking')),
            body: const Center(child: Text('Tradie information not available')),
          );
        },
      ),

      GoRoute(
        path: '/urgent-booking/service/:serviceId/tradie/:tradieId/profile',
        name: 'tradie-profile',
        builder: (context, state) {
          final serviceId =
              int.tryParse(state.pathParameters['serviceId'] ?? '') ?? 0;
          final tradieId =
              int.tryParse(state.pathParameters['tradieId'] ?? '') ?? 0;
          final tradie = state.extra as TradieRecommendation?;
          if (tradie != null) {
            return TradieProfileScreen(tradie: tradie, jobId: serviceId);
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Tradie Profile')),
            body: const Center(child: Text('Tradie information not available')),
          );
        },
      ),

      // ---------------------------------------------------------------------
      // BOOKINGS MANAGEMENT
      // ---------------------------------------------------------------------
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),

      GoRoute(
        path: '/bookings/:id',
        name: 'booking-details',
        builder: (context, state) {
          final bookingId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return BookingDetailsScreen(bookingId: bookingId);
        },
      ),

      GoRoute(
        path: '/bookings/:id/in-progress',
        name: 'job-in-progress',
        builder: (context, state) {
          final bookingId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return JobInProgressScreen(bookingId: bookingId);
        },
      ),

      GoRoute(
        path: '/bookings/:id/cancel',
        name: 'cancel-booking',
        builder: (context, state) {
          final bookingId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CancellationRequestScreen(bookingId: bookingId);
        },
      ),

      GoRoute(
        path: '/bookings/:id/cancel-success',
        name: 'cancel-success',
        builder: (context, state) {
          final refNumber = state.uri.queryParameters['ref'] ?? '';
          return CancellationSuccessScreen(referenceNumber: refNumber);
        },
      ),
    ],

    /// ERROR PAGE
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
