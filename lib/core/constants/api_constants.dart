class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  //static const String baseUrl = 'https://fixog4-avbhhghkdxgag5cc.southeastasia-01.azurewebsites.net/api';

  // ============================================================================
  // OLD AUTH ENDPOINTS (features/auth) - DEPRECATED, USE auth_otp ENDPOINTS BELOW
  // ============================================================================
  // static const String loginEndpoint = '/homeowner/login';
  // static const String registerEndpoint = '/homeowner/register';
  // static const String logoutEndpoint = '/homeowner/logout';
  // static const String refreshTokenEndpoint = '/homeowner/refresh';

  // Service Endpoints (Homeowner Job Requests)
  static const String servicesEndpoint = '/services';
  static String serviceById(int id) => '/services/$id';

  // Job Request Endpoints (for tradie recommendations)
  static const String jobsEndpoint = '/jobs';
  static String jobById(int id) => '/jobs/$id';
  static String jobRecommendTradies(int jobId) =>
      '/jobs/$jobId/recommend-tradies';

  // Booking Endpoints
  static const String bookingsEndpoint = '/bookings';
  static String bookingById(int id) => '/bookings/$id';
  static String bookingHistory = '/bookings/history';
  static String cancelBooking(int id) => '/bookings/$id/cancel';

  // Urgent Booking Endpoints (new)
  static const String urgentBookings = '/urgent-bookings';
  static String urgentBookingById(int id) => '/urgent-bookings/$id';
  static String urgentBookingRecommendations(int id) =>
      '/urgent-bookings/$id/recommendations';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // ============================================================================
  // AUTH_OTP ENDPOINTS (features/auth_otp) - ACTIVE ENDPOINTS
  // ============================================================================
  static const String requestOtp = '/homeowner/request-otp';
  static const String verifyOtp = '/homeowner/verify-otp';
  static const String login = '/homeowner/login';
  static const String register = '/homeowner/register';
  static const String resetPasswordRequest =
      '/homeowner/reset-password-request';
  // Reset password route doesn't include userId (uses authenticated user)
  static const String resetPasswordRoute = '/homeowner/reset-password';
  static const String me = '/homeowner/me';
  static const String logout = '/homeowner/logout';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
