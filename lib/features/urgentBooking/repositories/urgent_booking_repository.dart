import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_result.dart';
import '../models/service_model.dart';
import '../models/tradie_recommendation.dart';

class UrgentBookingRepository {
  final Dio _dio = DioClient.instance.dio;

  UrgentBookingRepository();

  /// Fetch all services
  Future<ApiResult<List<ServiceModel>>> fetchServices({
    String? status,
    int page = 1,
  }) async {
    try {
      final resp = await _dio.get(
        '/services',
        queryParameters: {if (status != null) 'status': status, 'page': page},
      );

      final body = resp.data;
      List items = [];

      // Handle different response formats
      if (body is List) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        if (body['data'] is List) {
          items = List.from(body['data']);
        } else if (body['services'] is List) {
          items = List.from(body['services']);
        }
      }

      final services = items
          .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return Success(services);
    } on DioException catch (e) {
      return _handleDioError<List<ServiceModel>>(
        e,
        defaultMessage: 'Failed to fetch services',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Create a new service request
  Future<ApiResult<ServiceModel>> createService({
    required int homeownerId,
    required int jobCategoryId,
    required String jobDescription,
    required String location,
    String status = 'Pending',
    int? rating,
  }) async {
    try {
      final data = {
        'homeowner_id': homeownerId,
        'job_categoryid': jobCategoryId,
        'job_description': jobDescription,
        'location': location,
        'status': status,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        if (rating != null) 'rating': rating,
      };

      final resp = await _dio.post('/services', data: data);
      final body = resp.data;

      ServiceModel service;
      if (body is Map<String, dynamic>) {
        service = ServiceModel.fromJson(body);
      } else {
        return Failure(message: 'Invalid service response');
      }

      return Success(service);
    } on DioException catch (e) {
      return _handleDioError<ServiceModel>(
        e,
        defaultMessage: 'Failed to create service',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Get service details by ID
  Future<ApiResult<ServiceModel>> getServiceById(int serviceId) async {
    try {
      final resp = await _dio.get('/services/$serviceId');
      final body = resp.data;

      ServiceModel service;
      if (body is Map<String, dynamic>) {
        service = ServiceModel.fromJson(body);
      } else {
        return Failure(message: 'Invalid service response');
      }

      return Success(service);
    } on DioException catch (e) {
      return _handleDioError<ServiceModel>(
        e,
        defaultMessage: 'Failed to fetch service details',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Update service
  Future<ApiResult<ServiceModel>> updateService(
    int serviceId, {
    int? homeownerId,
    int? jobCategoryId,
    String? jobDescription,
    String? location,
    String? status,
    int? rating,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (homeownerId != null) data['homeowner_id'] = homeownerId;
      if (jobCategoryId != null) data['job_categoryid'] = jobCategoryId;
      if (jobDescription != null) data['job_description'] = jobDescription;
      if (location != null) data['location'] = location;
      if (status != null) data['status'] = status;
      if (rating != null) data['rating'] = rating;

      final resp = await _dio.put('/services/$serviceId', data: data);
      final body = resp.data;

      ServiceModel service;
      if (body is Map<String, dynamic>) {
        service = ServiceModel.fromJson(body);
      } else {
        return Failure(message: 'Invalid service response');
      }

      return Success(service);
    } on DioException catch (e) {
      return _handleDioError<ServiceModel>(
        e,
        defaultMessage: 'Failed to update service',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Delete service
  Future<ApiResult<void>> deleteService(int serviceId) async {
    try {
      await _dio.delete('/services/$serviceId');
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError<void>(
        e,
        defaultMessage: 'Failed to delete service',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Get tradie recommendations for a service
  Future<ApiResult<TradieRecommendationResponse>> getTradieRecommendations(
    int serviceId, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final resp = await _dio.get(
        '/jobs/$serviceId/recommend-tradies',
        queryParameters: queryParams,
      );
      final body = resp.data;

      TradieRecommendationResponse response;
      if (body is Map<String, dynamic>) {
        response = TradieRecommendationResponse.fromJson(body);
      } else {
        return Failure(message: 'Invalid recommendations response');
      }

      return Success(response);
    } on DioException catch (e) {
      return _handleDioError<TradieRecommendationResponse>(
        e,
        defaultMessage: 'Failed to fetch tradie recommendations',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Handle Dio errors
  ApiResult<T> _handleDioError<T>(
    DioException e, {
    String defaultMessage = 'Network error',
  }) {
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(e.response!.data);
      final message = data['message']?.toString() ?? defaultMessage;
      // final errors = data['errors'] is Map
      //     ? Map<String, List<String>>.from(data['errors'])
      //     : null;
      final errors = data['errors'] is Map
          ? (data['errors'] as Map).map(
              (key, value) =>
                  MapEntry(key.toString(), List<String>.from(value as List)),
            )
          : null;
      return Failure(
        message: message,
        statusCode: e.response?.statusCode,
        errors: errors,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const Failure(message: 'No internet connection.');
      default:
        return Failure(
          message: e.message ?? defaultMessage,
          statusCode: e.response?.statusCode,
        );
    }
  }
}
