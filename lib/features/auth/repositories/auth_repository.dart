import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient.instance;

  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );
      // Debug logs
      // ignore: avoid_print
      print('AuthRepository.login request: ${request.toJson()}');
      // ignore: avoid_print
      print('AuthRepository.login response: ${response.data}');

      // Support both direct credentials and wrapped under 'data', and 'token' or 'access_token'
      final raw = response.data;
      final payload = (raw is Map<String, dynamic> && raw.containsKey('data')) ? raw['data'] : raw;
      Map<String, dynamic> normalized;
      if (payload is Map<String, dynamic>) {
        normalized = Map<String, dynamic>.from(payload);
        if (!normalized.containsKey('access_token') && normalized.containsKey('token')) {
          normalized['access_token'] = normalized['token'];
          normalized['token_type'] = normalized['token_type'] ?? 'Bearer';
        }
      } else {
        return Failure(message: 'Invalid login response type: ${response.data}');
      }
      final authResponse = AuthResponse.fromJson(normalized);
      if (authResponse.accessToken.isEmpty) {
        return Failure(message: 'Missing access token in response');
      }
      try {
        await _dioClient.setToken(authResponse.accessToken);
      } catch (e) {
        return Failure(message: 'Failed to save token: $e');
      }

      return Success(authResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.registerEndpoint,
        data: request.toJson(),
      );

      // Debug logs
      // ignore: avoid_print
      print('AuthRepository.register request: ${request.toJson()}');
      // ignore: avoid_print
      print('AuthRepository.register response: ${response.data}');
      final raw = response.data;
      final payload = (raw is Map<String, dynamic> && raw.containsKey('data')) ? raw['data'] : raw;
      Map<String, dynamic> normalized;
      if (payload is Map<String, dynamic>) {
        normalized = Map<String, dynamic>.from(payload);
        if (!normalized.containsKey('access_token') && normalized.containsKey('token')) {
          normalized['access_token'] = normalized['token'];
          normalized['token_type'] = normalized['token_type'] ?? 'Bearer';
        }
      } else {
        return Failure(message: 'Invalid register response type: ${response.data}');
      }
      final authResponse = AuthResponse.fromJson(normalized);
      if (authResponse.accessToken.isEmpty) {
        return Failure(message: 'Missing access token in response');
      }
      try {
        await _dioClient.setToken(authResponse.accessToken);
      } catch (e) {
        return Failure(message: 'Failed to save token: $e');
      }

      return Success(authResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResult<void>> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logoutEndpoint);
      await _dioClient.clearToken();
      return const Success(null);
    } on DioException catch (e) {
      await _dioClient.clearToken(); // Clear token even if logout fails
      return _handleDioError(e);
    } catch (e) {
      await _dioClient.clearToken();
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _dioClient.getToken();
    return token != null;
  }

  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final apiError = ApiError.fromJson(data);
        return Failure(
          message: apiError.message ?? 'An error occurred',
          statusCode: e.response!.statusCode,
          errors: apiError.errors,
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