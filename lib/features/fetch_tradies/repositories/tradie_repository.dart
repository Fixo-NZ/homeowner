import 'package:dio/dio.dart';
import 'package:tradie/features/fetch_tradies/models/tradie_request.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_result.dart';
import '../models/tradie_model.dart';

class TradieRepository {
  final Dio _dio = DioClient.instance.dio;

  TradieRepository();

  Future<ApiResult<List<TradieRequest>>> fetchJobs({
    String? status,
    int page = 1,
  }) async {
    try {
      final resp = await _dio.get(
        '/tradie/jobs',
        queryParameters: {if (status != null) 'status': status, 'page': page},
      );

      final body = resp.data;
      List items = [];

      // Accept different shapes:
      // 1) controller returned -> { success: true, data: <PaginationObject> }
      // 2) or -> { data: [ ... ] }
      // 3) or raw list
      if (body is List) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        if (body['data'] is Map && body['data']['data'] is List) {
          items = List.from(body['data']['data']);
        } else if (body['data'] is List) {
          items = List.from(body['data']);
        } else if (body['jobs'] is List) {
          items = List.from(body['jobs']);
        } else if (body['items'] is List) {
          items = List.from(body['items']);
        }
      }

      final jobs = items
          .map((e) => TradieRequest.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Success(jobs);
    } on DioException catch (e) {
      return _handleDioError<List<TradieRequest>>(
        e,
        defaultMessage: 'Failed to fetch jobs',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<TradieRequest>> fetchJobDetail(int jobId) async {
    try {
      final resp = await _dio.get('/tradie/jobs/$jobId');
      final body = resp.data;
      Map<String, dynamic>? jobJson;

      if (body is Map<String, dynamic>) {
        if (body['data'] is Map<String, dynamic>) {
          jobJson = Map<String, dynamic>.from(body['data']);
        } else if (body['job'] is Map<String, dynamic>) {
          jobJson = Map<String, dynamic>.from(body['job']);
        } else {
          // maybe body is the job itself
          jobJson = body;
        }
      }

      if (jobJson == null) {
        return Failure(message: 'Invalid job response');
      }

      return Success(TradieRequest.fromJson(jobJson));
    } on DioException catch (e) {
      return _handleDioError<TradieRequest>(
        e,
        defaultMessage: 'Failed to fetch job details',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<List<TradieModel>>> fetchRecommendedTradies(
      int jobId,
      ) async {
    try {
      final resp = await _dio.get('/tradie/jobs/$jobId/recommend-tradies');
      final body = resp.data;
      List items = [];

      if (body is Map<String, dynamic>) {
        if (body['recommendations'] is List) {
          items = List.from(body['recommendations']);
        } else if (body['recommended_tradies'] is List) {
          items = List.from(body['recommended_tradies']);
        } else if (body['data'] is Map &&
            body['data']['recommendations'] is List) {
          items = List.from(body['data']['recommendations']);
        } else if (body['data'] is List) {
          items = List.from(body['data']);
        }
      } else if (body is List) {
        items = body;
      }

      final tradies = items
          .map((e) => TradieModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Success(tradies);
    } on DioException catch (e) {
      return _handleDioError<List<TradieModel>>(
        e,
        defaultMessage: 'Failed to fetch recommendations',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  ApiResult<T> _handleDioError<T>(
      DioException e, {
        String defaultMessage = 'Network error',
      }) {
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      final data = Map<String, dynamic>.from(e.response!.data);
      final message = data['message']?.toString() ?? defaultMessage;
      final errors = data['errors'] is Map
          ? Map<String, List<String>>.from(data['errors'])
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
