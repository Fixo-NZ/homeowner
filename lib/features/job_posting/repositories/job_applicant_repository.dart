import 'package:dio/dio.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/job_applicant_models.dart';

class JobApplicantRepository {
  final DioClient _dioClient = DioClient.instance;

  // Get applicants for a job
  Future<ApiResult<List<JobApplicant>>> getJobApplicants(int jobId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.jobApplicantsEndpoint}/$jobId/applicants',
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final applicants = data.map((app) => JobApplicant.fromJson(app)).toList();

      return Success(applicants);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Accept a tradie applicant
  Future<ApiResult<ApplicantActionResponse>> acceptApplicant(
    int jobId,
    int applicationId,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.acceptApplicantEndpoint}/$jobId/applicants/$applicationId/accept',
      );

      final actionResponse = ApplicantActionResponse.fromJson(response.data);
      return Success(actionResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Reject a tradie applicant
  Future<ApiResult<ApplicantActionResponse>> rejectApplicant(
    int jobId,
    int applicationId,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.rejectApplicantEndpoint}/$jobId/applicants/$applicationId/reject',
      );

      final actionResponse = ApplicantActionResponse.fromJson(response.data);
      return Success(actionResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Complete job (homeowner side)
  Future<ApiResult<ApplicantActionResponse>> completeJob(int jobId) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.completeJobEndpoint}/$jobId/complete',
      );

      final actionResponse = ApplicantActionResponse.fromJson(response.data);
      return Success(actionResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // Error handling
  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? 'An error occurred';
        return Failure(
          message: message,
          statusCode: e.response!.statusCode,
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