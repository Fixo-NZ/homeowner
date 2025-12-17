class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String baseUrl = 'https://fixo-apdkb5f3f0frdcgt.southeastasia-01.azurewebsites.net/api';
  static const String loginEndpoint = '/homeowner/login';
  
  static const String registerEndpoint = '/homeowner/register';
  static const String emailVerification = '/homeowner/verify-email/{id}/{hash}';
  static const String resendEmailVerificationEndpoint = '/homeowner/resend-verification-email';

  static const String resetPasswordEndpoint = '/homeowner/reset-password-request';
  static const String otpVerificationEndpoint = '/homeowner/verify-otp';
  static const String newPasswordEndpoint = '/homeowner/reset-password';

  static const String logoutEndpoint = '/homeowner/logout';
  static const String refreshTokenEndpoint = '/homeowner/refresh';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
