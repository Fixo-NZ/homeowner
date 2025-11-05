import 'package:dio/dio.dart';
import 'package:tradie/core/constants/api_constants.dart';
import 'package:tradie/core/network/api_result.dart';
import 'package:tradie/core/network/dio_client.dart';
import 'package:tradie/features/job_posting/models/job_posting_models.dart';


class JobPostingRepository {
  final DioClient _dioClient = DioClient.instance;

  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}',
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      final categories = data
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      return Success(categories);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // FIXED: Correct endpoint for category services
  Future<ApiResult<List<ServiceModel>>> getServicesByCategory(int categoryId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}/$categoryId/services',
      );

      final Map<String, dynamic> responseData = response.data['data'] ?? response.data;
      final List<dynamic> servicesData = responseData['services'] ?? [];
      
      final services = servicesData
          .map((service) => ServiceModel.fromJson(service))
          .toList();

      return Success(services);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResult<JobPostResponse>> createJobPost(JobPostRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}',
        data: request.toJson(),
      );

      final jobPostResponse = JobPostResponse.fromJson(response.data['data'] ?? response.data);
      return Success(jobPostResponse);
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