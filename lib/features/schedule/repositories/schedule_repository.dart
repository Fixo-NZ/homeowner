import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_result.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final Dio _dio = DioClient.instance.dio;

  ScheduleRepository();

  Future<ApiResult<List<OfferModel>>> fetchOffers({
    String? status,
    int page = 1,
  }) async {
    try {
      print('🔄 Fetching offers from: /schedules/homeowner');
      print('🌐 Base URL: ${_dio.options.baseUrl}');
      print('📋 Query params: ${{'status': status, 'page': page}}');
      
      final resp = await _dio.get(
        '/schedules/homeowner',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('✅ Response received: ${resp.statusCode}');
      final body = resp.data;
      print('📦 Response body type: ${body.runtimeType}');
      
      List items = [];

      // Handle different response shapes
      if (body is List) {
        items = body;
        print('📋 Found ${items.length} items in direct list');
      } else if (body is Map<String, dynamic>) {
        if (body['offers'] is List) {
          items = List.from(body['offers']);
          print('📋 Found ${items.length} items in offers array');
        } else if (body['data'] is Map && body['data']['offers'] is List) {
          items = List.from(body['data']['offers']);
          print('📋 Found ${items.length} items in data.offers array');
        } else if (body['data'] is List) {
          items = List.from(body['data']);
          print('📋 Found ${items.length} items in data array');
        }
      }

      print('🔄 Parsing ${items.length} offers...');
      final offers = <OfferModel>[];
      
      for (int i = 0; i < items.length; i++) {
        try {
          print('📝 Parsing offer $i: ${items[i].runtimeType}');
          final offerData = Map<String, dynamic>.from(items[i]);
          print('🔍 Offer $i data keys: ${offerData.keys.toList()}');
          
          // Check specific problematic fields
          print('🔍 Offer $i latitude: ${offerData['latitude']} (${offerData['latitude'].runtimeType})');
          print('🔍 Offer $i longitude: ${offerData['longitude']} (${offerData['longitude'].runtimeType})');
          print('🔍 Offer $i start_time: ${offerData['start_time']}');
          print('🔍 Offer $i end_time: ${offerData['end_time']}');
          
          final offer = OfferModel.fromJson(offerData);
          offers.add(offer);
          print('✅ Successfully parsed offer $i: ${offer.title}');
        } catch (e, stackTrace) {
          print('❌ Error parsing offer $i: $e');
          print('📍 Stack trace: $stackTrace');
          print('📋 Raw offer data: ${items[i]}');
          rethrow; // Re-throw to see the full error
        }
      }
      
      print('✅ Successfully parsed ${offers.length} offers');
      return Success(offers);
    } on DioException catch (e) {
      return _handleDioError<List<OfferModel>>(
        e,
        defaultMessage: 'Failed to fetch offers',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<OfferModel>> fetchOfferDetail(int offerId) async {
    try {
      final resp = await _dio.get('/schedules/homeowner/$offerId');
      final body = resp.data;
      Map<String, dynamic>? offerJson;

      if (body is Map<String, dynamic>) {
        if (body['data'] is Map<String, dynamic>) {
          offerJson = Map<String, dynamic>.from(body['data']);
        } else if (body['offer'] is Map<String, dynamic>) {
          offerJson = Map<String, dynamic>.from(body['offer']);
        } else {
          offerJson = body;
        }
      }

      if (offerJson == null) {
        return Failure(message: 'Invalid offer response');
      }

      return Success(OfferModel.fromJson(offerJson));
    } on DioException catch (e) {
      return _handleDioError<OfferModel>(
        e,
        defaultMessage: 'Failed to fetch offer details',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<OfferModel>> updateOfferStatus({
    required int offerId,
    required String status,
  }) async {
    try {
      final resp = await _dio.patch(
        '/schedules/homeowner/$offerId',
        data: {'status': status},
      );

      final body = resp.data;
      Map<String, dynamic>? offerJson;

      if (body is Map<String, dynamic>) {
        if (body['data'] is Map<String, dynamic>) {
          offerJson = Map<String, dynamic>.from(body['data']);
        } else if (body['offer'] is Map<String, dynamic>) {
          offerJson = Map<String, dynamic>.from(body['offer']);
        } else {
          offerJson = body;
        }
      }

      if (offerJson == null) {
        return Failure(message: 'Invalid response');
      }

      return Success(OfferModel.fromJson(offerJson));
    } on DioException catch (e) {
      return _handleDioError<OfferModel>(
        e,
        defaultMessage: 'Failed to update offer status',
      );
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<OfferModel>> rescheduleEvent({
    required int id,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Format dates to match the format that works in Postman
      final startTimeString = '${startTime.year.toString().padLeft(4, '0')}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeString = '${endTime.year.toString().padLeft(4, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.day.toString().padLeft(2, '0')} ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

      print("🚀 Sending reschedule request:");
      print("📅 Start Time: $startTimeString");
      print("📅 End Time: $endTimeString");

      final response = await _dio.post(
        '/schedules/$id/reschedule',
        data: {
          'start_time': startTimeString,
          'end_time': endTimeString,
        },
      );

      print("🔍 Reschedule response: ${response.statusCode}");
      print("🔍 Reschedule response data: ${response.data}");
      
      // If we get a 200 response, consider it successful
      if (response.statusCode == 200) {
        print("✅ Schedule updated successfully: $id");
        return Success(OfferModel(
          id: id,
          homeownerId: 0,
          serviceCategoryId: 0,
          tradieId: 0,
          jobType: '',
          title: '',
          jobSize: '',
          description: '',
          address: '',
          status: 'rescheduled',
          startTime: startTimeString,
          endTime: endTimeString,
          tradie: Tradie(
            id: 0,
            firstName: '',
            lastName: '',
            email: '',
            address: '',
            phone: '',
          ),
          category: Category(
            id: 0,
            name: '',
            description: '',
            icon: '',
            status: '',
          ),
        ));
      } else {
        return Failure(message: 'Failed to reschedule');
      }
    } on DioException catch (e) {
      print("❌ Reschedule API Error: ${e.response?.data}");
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      print("❌ Reschedule Error: $e");
      return Failure(message: 'Unexpected error: $e');
    }
  }

  Future<ApiResult<bool>> cancelSchedule(int id) async {
    try {
      final response = await _dio.post('/schedules/$id/cancel');
      
      print("🔍 Cancel response: ${response.statusCode}");
      print("🔍 Cancel response data: ${response.data}");
      
      // If we get a 200 response, consider it successful
      if (response.statusCode == 200) {
        print("✅ Schedule cancelled successfully: $id");
        return Success(true);
      } else {
        return Failure(message: 'Failed to cancel schedule');
      }
    } on DioException catch (e) {
      print("❌ Cancel API Error: ${e.response?.data}");
      return Failure(message: 'Network error: ${e.message}');
    } catch (e) {
      print("❌ Cancel Error: $e");
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