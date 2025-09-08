class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String loginEndpoint = '/homeowner/login';
  static const String registerEndpoint = '/homeowner/register';
  static const String logoutEndpoint = '/homeowner/logout';
  static const String refreshTokenEndpoint = '/tradie/refresh';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
