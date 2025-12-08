// import 'package:dio/dio.dart';
// import '../constants/api_constants.dart';
// import '../storage/secure_storage_service.dart';
//
// class ApiClient {
//   static final ApiClient _instance = ApiClient._internal();
//   factory ApiClient() => _instance;
//   ApiClient._internal();
//
//   late final Dio _dio;
//   final SecureStorageService _storage = SecureStorageService();
//
//   Dio get dio => _dio;
//
//   Future<void> init() async {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConstants.baseUrl,
//         connectTimeout: ApiConstants.connectTimeout,
//         receiveTimeout: ApiConstants.receiveTimeout,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );
//
//     // Add interceptors
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Add auth token to all requests
//           final token = await _storage.getToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },
//         onError: (DioException error, handler) async {
//           // Handle 401 Unauthorized (token expired or invalid)
//           if (error.response?.statusCode == 401) {
//             // Clear stored auth data
//             await _storage.clearAll();
//             // You can also trigger a logout event here
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//
//     // Add logging interceptor (remove in production)
//     _dio.interceptors.add(
//       LogInterceptor(
//         requestBody: true,
//         responseBody: true,
//         error: true,
//         requestHeader: true,
//         responseHeader: false,
//       ),
//     );
//   }
//
//   // Generic GET request
//   Future<Response> get(
//     String path, {
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return await _dio.get(
//       path,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   // Generic POST request
//   Future<Response> post(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return await _dio.post(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   // Generic PUT request
//   Future<Response> put(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return await _dio.put(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   // Generic DELETE request
//   Future<Response> delete(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return await _dio.delete(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
//
//   // Generic PATCH request
//   Future<Response> patch(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     return await _dio.patch(
//       path,
//       data: data,
//       queryParameters: queryParameters,
//       options: options,
//     );
//   }
// }
//
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Use SecureStorageService which is shared across the app
          final token = await _storage.getToken();
          
          if (token != null && token.isNotEmpty) {
            // Clean token (remove any whitespace)
            final cleanToken = token.trim();
            
            options.headers[ApiConstants.authorization] =
                '${ApiConstants.bearer} $cleanToken';
            
            // Debug: Log token status (remove in production)
            print('🔐 [AUTH] Token added to request: ${cleanToken.substring(0, cleanToken.length > 20 ? 20 : cleanToken.length)}...');
            print('🔐 [AUTH] Request URL: ${options.uri}');
          } else {
            print('❌ [AUTH] No token found in storage!');
            print('❌ [AUTH] Request URL: ${options.uri}');
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print('❌ [AUTH] 401 Unauthorized error!');
            print('❌ [AUTH] Response: ${error.response?.data}');
            print('❌ [AUTH] Request URL: ${error.requestOptions.uri}');
            
            // Check if token exists
            final token = await _storage.getToken();
            if (token == null) {
              print('❌ [AUTH] Token is null - user needs to login');
            } else {
              print('⚠️ [AUTH] Token exists but was rejected: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
            }
            
            await _storage.deleteToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    await _storage.saveToken(token);
  }

  Future<void> clearToken() async {
    await _storage.deleteToken();
  }

  Future<String?> getToken() async {
    return await _storage.getToken();
  }
}
