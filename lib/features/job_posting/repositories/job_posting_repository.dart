import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/job_posting/models/job_posting_models.dart';
import '../../auth/repositories/auth_repository.dart';

class JobPostingRepository {
  final DioClient _dioClient = DioClient.instance;
  final AuthRepository _authRepository = AuthRepository();

  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}',
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      final categories =
          data.map((category) => CategoryModel.fromJson(category)).toList();

      return Success(categories);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResult<List<ServiceModel>>> getServicesByCategory(
      int categoryId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}/$categoryId/services',
      );

      // Handle the nested response structure
      final dynamic data = response.data;

      List<dynamic> servicesData = [];

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          servicesData = data['data']['services'] ?? [];
        } else if (data.containsKey('services')) {
          servicesData = data['services'] ?? [];
        }
      }

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

/*   Future<ApiResult<JobPostResponse>> createJobPost(JobPostRequest request) async {
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
  } */

  Future<ApiResult<JobPostResponse>> createJobPost(
      JobPostRequest request) async {
    try {
      // Get current user ID from auth repository
      final int? homeownerId = await _authRepository.getCurrentUserId();

      if (homeownerId == null) {
        return Failure(message: 'User not authenticated. Please login again.');
      }

      // Convert request to JSON
      final Map<String, dynamic> requestData = request.toJson();
      requestData['homeowner_id'] = homeownerId;

      // DEBUG PRINTING
      print('🚀 === SENDING JOB POST REQUEST ===');
      print('📤 URL: ${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}');
      print('  HOMEOWNER ID: $homeownerId (from auth)');
      print('📦 FULL PAYLOAD: $requestData');
      print('🔍 SERVICES FIELD: ${requestData['services']}');
      print('🔍 CATEGORY ID: ${requestData['service_category_id']}');
      print('🔍 HOMEOWNER ID: ${requestData['homeowner_id']}');
      print('===================================');

      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}',
        data: requestData, // ← Use the modified data
      );

      // DEBUG PRINTING - Success Response
      print('✅ === JOB POST SUCCESS ===');
      print('📥 STATUS CODE: ${response.statusCode}');
      print('📄 RESPONSE DATA: ${response.data}');
      print('===========================');

      // FIX: Handle the nested response structure properly
      final responseData = response.data;
      dynamic dataToParse;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          // Response has {success: true, message: "...", data: {...}}
          dataToParse = responseData['data'];
          print('🔍 PARSING FROM: response.data[\'data\']');
        } else {
          // Response is the data object directly
          dataToParse = responseData;
          print('🔍 PARSING FROM: response.data directly');
        }
      } else {
        dataToParse = responseData;
      }

      print('🔍 DATA TO PARSE: $dataToParse');

      final jobPostResponse = JobPostResponse.fromJson(dataToParse);
      return Success(jobPostResponse);
    } on DioException catch (e) {
      // DEBUG PRINTING - Dio Error
      print('❌ === JOB POST DIO ERROR ===');
      print('💥 ERROR TYPE: ${e.type}');
      print('📊 STATUS CODE: ${e.response?.statusCode}');
      print('📝 ERROR MESSAGE: ${e.message}');
      print('🔍 ERROR RESPONSE DATA: ${e.response?.data}');
      print('=============================');

      return _handleDioError(e);
    } catch (e) {
      // DEBUG PRINTING - General Error
      print('❌ === UNEXPECTED ERROR ===');
      print('💥 ERROR: $e');
      print('📋 ERROR TYPE: ${e.runtimeType}');
      if (e is TypeError) {
        print('🔍 TYPE ERROR DETAILS: $e');
      }
      print('===========================');

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

  // Get all job offers for current user
  Future<ApiResult<List<JobListResponse>>> getJobOffers() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}',
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final jobOffers =
          data.map((job) => JobListResponse.fromJson(job)).toList();

      return Success(jobOffers);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

// Get single job offer details
  Future<ApiResult<JobPostResponse>> getJobOfferDetails(int jobId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}/$jobId',
      );

      final data = response.data['data'] ?? response.data;
      final jobOffer = JobPostResponse.fromJson(data);

      return Success(jobOffer);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

// Delete job offer
  Future<ApiResult<void>> deleteJobOffer(int jobId) async {
    try {
      await _dioClient.dio.delete(
        '${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}/$jobId',
      );

      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

// Update job offer
  Future<ApiResult<JobPostResponse>> updateJobOffer(
    int jobId,
    JobPostRequest request,
  ) async {
    try {
      final int? homeownerId = await _authRepository.getCurrentUserId();
      if (homeownerId == null) {
        return Failure(message: 'User not authenticated. Please login again.');
      }

      final Map<String, dynamic> requestData = request.toJson();
      requestData['homeowner_id'] = homeownerId;

      final response = await _dioClient.dio.put(
        '${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}/$jobId',
        data: requestData,
      );

      final responseData = response.data;
      dynamic dataToParse;

      if (responseData is Map<String, dynamic>) {
        dataToParse = responseData['data'] ?? responseData;
      } else {
        dataToParse = responseData;
      }

      final jobPostResponse = JobPostResponse.fromJson(dataToParse);
      return Success(jobPostResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }
}
