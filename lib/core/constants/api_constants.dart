class ApiConstants {
 static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String loginEndpoint = '/homeowner/login';
  static const String registerEndpoint = '/homeowner/register';
  static const String logoutEndpoint = '/homeowner/logout';
  static const String refreshTokenEndpoint = '/homeowner/refresh';

  // Urgent Booking Endpoints
  static const String servicesEndpoint = '/services';
  static String serviceById(int id) => '/services/$id';
  static String serviceRecommendations(int serviceId) =>
      '/services/$serviceId/recommend-tradies';

  // Urgent Booking Endpoints (new)
  static const String urgentBookings = '/urgent-bookings';
  static String urgentBookingById(int id) => '/urgent-bookings/$id';
  static String urgentBookingRecommendations(int id) =>
      '/urgent-bookings/$id/recommendations';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  //payment endpoints
  static const String paymentProcess = '/payment/process';
    // Saved payments endpoints
    
    static const String paymentsList = '/payments';
    static const String paymentsHistory = '/payments/history';
    static const String paymentsSave = '/payments/save-payment-method';
    static const String savedCards = '/saved-cards';
    static String paymentDecrypt(String id) => '/payments/$id/decrypt';
    static String paymentDelete(String id) => '/payments/$id/delete';
    static String paymentUpdate(String id) => '/payments/$id/update';
}
