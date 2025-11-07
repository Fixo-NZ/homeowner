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

  Future<ApiResult<List<ServiceModel>>> getServicesByCategory(int categoryId) async {
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

Future<ApiResult<JobPostResponse>> createJobPost(JobPostRequest request) async {
  try {
    // Convert request to JSON and add homeowner_id
    final Map<String, dynamic> requestData = request.toJson();
    requestData['homeowner_id'] = 1; // ← ADD THIS LINE 
    
    // DEBUG PRINTING
    print('🚀 === SENDING JOB POST REQUEST ===');
    print('📤 URL: ${ApiConstants.baseUrl}${ApiConstants.jobOffersEndpoint}');
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
}