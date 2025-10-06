import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../models/job_category_model.dart';

class JobRepository {
  final DioClient _dioClient = DioClient.instance;

  Future<ApiResult<List<JobCategory>>> getJobCategories() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.jobCategoryEndpoint,
      );
      final jobCategories =
          (response.data as List).map((e) => JobCategory.fromJson(e)).toList();

      return Success(jobCategories);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return Failure(
          message: data['message'] ?? 'Request failed',
          statusCode: e.response!.statusCode,
          errors: (data['errors'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          ),
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
