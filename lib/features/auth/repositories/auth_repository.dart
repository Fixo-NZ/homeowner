import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

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

      final authResponse = AuthResponse.fromJson(responseData['data']);

      await _dioClient.setToken(authResponse.accessToken);

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
        await _secureStorage.write(key: _tokenKey, value: authResponse.accessToken);
        await _dioClient.setToken(authResponse.accessToken);

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
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      await _dioClient.setToken(token);
      return true;
    }
    return false;
  }

  // HANDLE ERRORS
  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final apiError = ApiError.fromJson(data);
        return Failure(
          message: apiError.message ?? 'An unknown error occurred.',
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