class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageBaseUrl = 'http://10.0.2.2:8000/storage';

  // Auth Endpoints
  static const String loginEndpoint = '/homeowner/login';
  static const String registerEndpoint = '/homeowner/register';
  static const String logoutEndpoint = '/homeowner/logout';
  static const String refreshTokenEndpoint = '/homeowner/refresh';

  // Job Posting Endpoints
  static const String categoriesEndpoint = '/jobs/categories';
  static const String jobOffersEndpoint = '/jobs/job-offers';

  // Homeowner Job Application Endpoints
  static const String jobApplicantsEndpoint =
      '/homeowner/jobs'; // Will append /{id}/applicants
  static const String acceptApplicantEndpoint =
      '/homeowner/jobs'; // Will append /{id}/applicants/{applicationId}/accept
  static const String rejectApplicantEndpoint =
      '/homeowner/jobs'; // Will append /{id}/applicants/{applicationId}/reject
  static const String completeJobEndpoint =
      '/homeowner/jobs'; // Will append /{id}/complete

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
