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

      final authResponse = AuthResponse.fromJson(response.data);
      await _dioClient.setToken(authResponse.accessToken);

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

      final authResponse = AuthResponse.fromJson(response.data);
      await _dioClient.setToken(authResponse.accessToken);

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
          message: apiError.message,
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
