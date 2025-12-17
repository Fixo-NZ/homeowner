import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/home_owner_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'access_token';

AuthRepository._internal() 
    : _dioClient = DioClient.instance, 
      _secureStorage = const FlutterSecureStorage();

  factory AuthRepository() {
    return _instance;
  }
  static final AuthRepository _instance = AuthRepository._internal();

  AuthRepository.withClient(this._dioClient, this._secureStorage);

  // LOGIN
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      final responseData = response.data;

      var authResponse = AuthResponse.fromJson(responseData['data']);

      try {
        final rawUser = responseData['data']?['user'];
        if (rawUser is Map && rawUser['status'] != null) {
          final status = rawUser['status'].toString().toLowerCase();
          if (status == 'active' || status == 'verified') {
            final verifiedUser = authResponse.user.copyWith(emailVerifiedAt: DateTime.now());
            authResponse = AuthResponse(
              accessToken: authResponse.accessToken,
              tokenType: authResponse.tokenType,
              expiresIn: authResponse.expiresIn,
              user: verifiedUser,
            );
          }
        }
      } catch (_) {
        // ignore parsing errors and fall back to original authResponse
      }

      await _dioClient.setToken(authResponse.accessToken);

  // Also persist the token in this repository's secure storage to make
  // sure isLoggedIn() can read it reliably on app restart.
  await _secureStorage.write(key: _tokenKey, value: authResponse.accessToken);

      return Success(authResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // REGISTER
  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.registerEndpoint,
        data: request.toJson(),
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        final authResponse = AuthResponse.fromJson(responseData['data']);
        return Success(authResponse);
      } else {
        return Failure(message: 'Invalid response format from server.');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // EMAIL VERIFICATION 
  Future<ApiResult<bool>> verifyEmail(String email, String token) async {
    try {
      await _dioClient.dio.post(
        '/homeowner/verify-email',
        data: {
          'email': email,
          'token': token,
        },
      );

      return const Success(true);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  //RESEND EMAIL VERIFICATION
  Future<ApiResult<bool>> resendVerification(String email) async {
    try {
      final response = await _dioClient.dio.post(
        '/homeowner/resend-verification',
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Success(true);
      }

      return Failure(message: "Failed to resend verification email.");
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: "Unexpected error: $e");
    }
  }

  // RESET PASSWORD REQUEST
  Future<ApiResult<bool>> requestPasswordReset(String email) async {
    try {
      final response = await _dioClient.dio.post(
        '/homeowner/reset-password-request', 
        data: {
          'email': email,
        },
      );

      // Log response for debugging
      print('AuthRepository.requestPasswordReset: status=${response.statusCode} data=${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend may return a boolean status or a data object. Check common shapes.
        if (response.data is Map) {
          final data = response.data as Map;
          // If backend provides an explicit status flag
          if (data.containsKey('status')) {
            final statusVal = data['status'];
            if (statusVal == true || statusVal == 'success') {
              return const Success(true);
            }
            // Try to extract message
            final message = data['message']?.toString() ?? 'Failed to send password reset request';
            return Failure(message: message);
          }
        }

        // If no explicit status field but 200/201, treat as success
        return const Success(true);
      }

      // Non-2xx status: try to surface error message
      String message = 'Failed to send password reset request';
      if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      }
      return Failure(message: message);
    } on DioException catch (e) {
      print('AuthRepository.requestPasswordReset DioException: ${e.response?.statusCode} ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      print('AuthRepository.requestPasswordReset exception: $e');
      return Failure(message: 'Unexpected error: $e');
    }
  }

  // RESET PASSWORD OTP VERIFICATION (used for forgot-password flow)
Future<ApiResult<bool>> verifyResetPasswordOtp(String email, String otp) async {
  try {
    final response = await _dioClient.dio.post(
      ApiConstants.otpVerificationEndpoint,
      data: {
        'email': email,
        'otp_code': otp,
      },
    );

    // if your backend returns token on success, you should parse and set it.
    // But the controller earlier returns authorisation token for existing user.
    // If backend returns authorisation data, extract it here and set token.
    if (response.data is Map && response.data['authorisation'] != null) {
      final auth = response.data['authorisation'];
      final accessToken = auth['access_token'] as String?;
      if (accessToken != null) {
        await _secureStorage.write(key: _tokenKey, value: accessToken);
        await _dioClient.setToken(accessToken);
      }
    }

    return const Success(true);
  } on DioException catch (e) {
    return _handleDioError(e);
  } catch (e) {
    return Failure(message: 'Unexpected error: $e');
  }
}

//PASSWORD RESET
  Future<ApiResult<bool>> resetPassword({
  required String email,
  required String newPassword,
  required String confirmNewPassword,
}) async {
  try {
    final response = await _dioClient.dio.post(
      '/homeowner/reset-password',
      data: {
        'email': email,
        'new_password': newPassword,
        'new_password_confirmation': confirmNewPassword,
      },
    );

    return const Success(true);
  } on DioException catch (e) {
    return _handleDioError(e);
  } catch (e) {
    return Failure(message: 'Unexpected error: $e');
  }
}

  // LOGOUT
  Future<ApiResult<void>> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logoutEndpoint);
      await _dioClient.clearToken();
      await _secureStorage.delete(key: _tokenKey);
      return const Success(null);
    } on DioException catch (e) {
      await _dioClient.clearToken();
      await _secureStorage.delete(key: _tokenKey);
      return _handleDioError(e);
    } catch (e) {
      await _dioClient.clearToken();
      await _secureStorage.delete(key: _tokenKey);
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // LOGIN STATUS
  Future<bool> isLoggedIn() async {
    // Read token via the DioClient storage to ensure a single source of truth
    final token = await _dioClient.getToken();
    print('AuthRepository.isLoggedIn: token=${token != null ? '[REDACTED]' : 'null'}');
    if (token != null && token.isNotEmpty) {
      // Ensure Dio instance has the token set for headers
      await _dioClient.setToken(token);
      return true;
    }
    return false;
  }

  /// Fetch the current authenticated homeowner profile from the API.
  /// Returns Success(HomeOwnerModel) on 200 and Failure otherwise.
  Future<ApiResult<HomeOwnerModel>> fetchCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/homeowner/me');
      final data = response.data;

      // Common shapes: { data: { user fields } } or { user fields }
      Map<String, dynamic>? payload;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          payload = data['data'] as Map<String, dynamic>;
        } else {
          payload = data;
        }
      }

      if (payload != null) {
        final user = HomeOwnerModel.fromJson(payload);
        return Success(user);
      }

      return Failure(message: 'Invalid user response from server.');
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  // HANDLE ERRORS
  ApiResult<T> _handleDioError<T>(DioException e) {
  if (e.response != null) {
    final data = e.response!.data;

    if (data is Map<String, dynamic>) {
      final errorData = data['error'] ?? data;

      final apiError = ApiError.fromJson(errorData);
      return Failure(
        message: apiError.message ?? 'An unknown error occurred.',
        statusCode: e.response!.statusCode,
        errors: apiError.details, 
        code: apiError.code,
      );
    }
  }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const Failure(message: 'No internet connection.');
      default:
        return Failure(message: 'Network error: ${e.message}');
    }
  }
}