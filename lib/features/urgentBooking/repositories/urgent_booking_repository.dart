import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_result.dart';
import '../models/service_model.dart';
import '../models/tradie_recommendation.dart';
import '../models/urgent_booking_model.dart';

class UrgentBookingRepository {
  final Dio _dio = DioClient.instance.dio;

  UrgentBookingRepository();

  /// 🔹 List urgent bookings for current user
  /// ⚠️ WARNING: This endpoint doesn't exist in Laravel yet
  /// TODO: Add GET /api/urgent-bookings endpoint to Laravel
  /// NOTE: Currently, urgent bookings can be tracked via regular /api/bookings with status filtering
  Future<ApiResult<List<UrgentBookingModel>>> fetchUrgentBookings() async {
    try {
      // ⚠️ This endpoint doesn't exist in Laravel - will return 404
      final resp = await _dio.get(ApiConstants.urgentBookings);
      final body = resp.data;

      List list = [];
      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic> && body['data'] is List) {
        list = List.from(body['data']);
      }

      final bookings = list
          .map((e) => UrgentBookingModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
      return Success(bookings);
    } on DioException catch (e) {
      return _handleDioError<List<UrgentBookingModel>>(
        e,
        defaultMessage: 'Failed to fetch urgent bookings',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Fetch all services
  /// ⚠️ WARNING: This endpoint doesn't exist in Laravel yet
  /// TODO: Add GET /api/services endpoint to Laravel
  Future<ApiResult<List<ServiceModel>>> fetchServices({
    String? status,
    int page = 1,
  }) async {
    try {
      // ⚠️ This endpoint doesn't exist in Laravel - will return 404
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

  /// 🔹 Create an urgent booking (consolidated)
  /// ⚠️ WARNING: This endpoint doesn't exist in Laravel yet
  /// TODO: Add POST /api/urgent-bookings endpoint to Laravel
  /// NOTE: Regular bookings are created via /api/bookings in booking_flow_screen.dart
  Future<ApiResult<UrgentBookingModel>> createUrgentBooking({
    required int jobId,
    int? tradieId,
    String? notes,
    String? priorityLevel,
    String? serviceName,
    String? preferredDate,
    String? preferredTimeWindow,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    try {
      final data = {
        'job_id': jobId,
        if (tradieId != null) 'tradie_id': tradieId,
        if (notes != null) 'notes': notes,
        if (priorityLevel != null) 'priority_level': priorityLevel,
        if (serviceName != null) 'service_name': serviceName,
        if (preferredDate != null) 'preferred_date': preferredDate,
        if (preferredTimeWindow != null)
          'preferred_time_window': preferredTimeWindow,
        if (contactName != null) 'contact_name': contactName,
        if (contactEmail != null) 'contact_email': contactEmail,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (address != null) 'address': address,
      };

      // ⚠️ This endpoint doesn't exist in Laravel - will return 404
      // Consider using /api/bookings instead and add a priority/urgent flag
      final response = await _dio.post(ApiConstants.urgentBookings, data: data);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        // Laravel returns { success: true, message: "...", booking: {...} }
        // OR direct booking object
        final bookingData = body.containsKey('booking') && body['booking'] is Map<String, dynamic>
            ? body['booking'] as Map<String, dynamic>
            : body;
        return Success(UrgentBookingModel.fromJson(bookingData));
      }

      return Failure(message: 'Invalid urgent booking response');
    } on DioException catch (e) {
      return _handleDioError<UrgentBookingModel>(
        e,
        defaultMessage: 'Failed to create urgent booking',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// 🔹 Get a single urgent booking by ID
  Future<ApiResult<UrgentBookingModel>> getUrgentBookingById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.urgentBookingById(id));
      final body = response.data;

      if (body is Map<String, dynamic>) {
        // Laravel returns { success: true, message: "...", booking: {...} }
        // OR direct booking object
        final bookingData = body.containsKey('booking') && body['booking'] is Map<String, dynamic>
            ? body['booking'] as Map<String, dynamic>
            : body;
        return Success(UrgentBookingModel.fromJson(bookingData));
      } else {
        return Failure(message: 'Invalid urgent booking response');
      }
    } on DioException catch (e) {
      return _handleDioError<UrgentBookingModel>(
        e,
        defaultMessage: 'Failed to fetch urgent booking details',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// 🔹 Update urgent booking
  Future<ApiResult<UrgentBookingModel>> updateUrgentBooking(
    int id, {
    String? status,
    int? tradieId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (tradieId != null) data['tradie_id'] = tradieId;

      final response =
      await _dio.put(ApiConstants.urgentBookingById(id), data: data);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        // Laravel returns { success: true, message: "...", booking: {...} }
        // OR direct booking object
        final bookingData = body.containsKey('booking') && body['booking'] is Map<String, dynamic>
            ? body['booking'] as Map<String, dynamic>
            : body;
        return Success(UrgentBookingModel.fromJson(bookingData));
      } else {
        return Failure(message: 'Invalid update response');
      }
    } on DioException catch (e) {
      return _handleDioError<UrgentBookingModel>(
        e,
        defaultMessage: 'Failed to update urgent booking',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Create a new service request (homeowner job request)
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
        if (rating != null) 'rating': rating,
      };

      final resp = await _dio.post('/services', data: data);
      final body = resp.data;

      ServiceModel service;
      if (body is Map<String, dynamic>) {
        // Handle Laravel response: { data: {...} } or direct service object
        if (body['data'] is Map<String, dynamic>) {
          service = ServiceModel.fromJson(body['data']);
        } else {
          service = ServiceModel.fromJson(body);
        }
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
        // Handle Laravel response: { data: {...} } or direct service object
        if (body['data'] is Map<String, dynamic>) {
          service = ServiceModel.fromJson(body['data']);
        } else {
          service = ServiceModel.fromJson(body);
        }
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
      final data = <String, dynamic>{};

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
        // Handle Laravel response: { data: {...} } or direct service object
        if (body['data'] is Map<String, dynamic>) {
          service = ServiceModel.fromJson(body['data']);
        } else {
          service = ServiceModel.fromJson(body);
        }
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
  /// Note: Services are homeowner job requests. We need to find/create a job request
  /// and then get recommendations for that job request.
  /// 
  /// Flow:
  /// 1. Get the service details
  /// 2. Find or create a matching job request
  /// 3. Get recommendations for that job request
  Future<ApiResult<TradieRecommendationResponse>> getTradieRecommendations(
    int serviceId, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      // First, get the service to find its details
      final serviceResult = await getServiceById(serviceId);
      if (serviceResult is Failure) {
        return Failure(message: 'Failed to fetch service: ${serviceResult.message}');
      }
      
      final service = (serviceResult as Success<ServiceModel>).data;
      
      // Try to find a matching job request for this service
      // Search for job requests with the same category and homeowner
      int? jobId;
      try {
        final jobsResp = await _dio.get(
          '/jobs',
          queryParameters: {
            'homeowner_id': service.homeownerId,
          },
        );
        
        List jobsList = [];
        if (jobsResp.data is Map<String, dynamic>) {
          if (jobsResp.data['success'] == true && jobsResp.data['data'] is Map) {
            final jobsData = jobsResp.data['data'];
            if (jobsData['data'] is List) {
              jobsList = jobsData['data'];
            }
          } else if (jobsResp.data['data'] is List) {
            jobsList = jobsResp.data['data'];
          }
        } else if (jobsResp.data is List) {
          jobsList = jobsResp.data;
        }
        
        // Find a job request with matching category
        for (var job in jobsList) {
          if (job is Map<String, dynamic>) {
            final jobCategoryId = job['job_category_id'] ?? job['category_id'];
            if (jobCategoryId == service.jobCategoryId) {
              jobId = job['id'] is int ? job['id'] : int.tryParse('${job['id']}');
              break;
            }
          }
        }
      } catch (e) {
        // If fetching jobs fails, we'll try to create one
      }
      
      // If no job request found, create one based on the service
      if (jobId == null) {
        try {
          final createJobResp = await _dio.post('/jobs', data: {
            'homeowner_id': service.homeownerId,
            'job_category_id': service.jobCategoryId,
            'title': service.jobDescription.length > 100 
                ? service.jobDescription.substring(0, 100) 
                : service.jobDescription,
            'description': service.jobDescription,
            'job_type': 'urgent',
            'status': 'pending',
            'location': service.location,
            'budget': null,
          });
          
          if (createJobResp.data is Map<String, dynamic>) {
            final jobData = createJobResp.data['data'] ?? createJobResp.data;
            if (jobData is Map<String, dynamic>) {
              jobId = jobData['id'] is int 
                  ? jobData['id'] 
                  : int.tryParse('${jobData['id']}');
            }
          }
        } catch (e) {
          return Failure(
            message: 'Failed to create job request for recommendations: $e',
          );
        }
      }
      
      if (jobId == null) {
        return Failure(
          message: 'Unable to find or create a job request for recommendations.',
        );
      }
      
      // Now get recommendations for the job request
      final resp = await _dio.get(
        '/jobs/$jobId/recommend-tradies',
        queryParameters: queryParams,
      );
      final body = resp.data;

      // Laravel returns: { success: true, count: X, data: [...] }
      TradieRecommendationResponse response;
      if (body is Map<String, dynamic>) {
        List<TradieRecommendation> recommendations = [];
        
        if (body['success'] == true && body['data'] is List) {
          final tradiesList = body['data'] as List;
          recommendations = tradiesList
              .map((e) => TradieRecommendation.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        
        response = TradieRecommendationResponse(
          success: body['success'] == true,
          message: body['message'] ?? 'Recommendations fetched successfully',
          serviceId: serviceId,
          recommendations: recommendations,
        );
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

  /// Get tradie recommendations for a booking
  Future<ApiResult<List<TradieRecommendation>>> getBookingRecommendations(
    int bookingId, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final resp = await _dio.get(
        ApiConstants.urgentBookingRecommendations(bookingId),
        queryParameters: queryParams,
      );
      final body = resp.data;

      List list = [];
      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic> && body['data'] is List) {
        list = List.from(body['data']);
      }

      final recs = list
          .map((e) => TradieRecommendation.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();

      return Success(recs);
    } on DioException catch (e) {
      return _handleDioError<List<TradieRecommendation>>(
        e,
        defaultMessage: 'Failed to fetch booking recommendations',
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
