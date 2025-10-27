import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/features/urgentBooking/viewmodels/urgent_booking_viewmodel.dart';
import 'package:tradie/features/urgentBooking/repositories/urgent_booking_repository.dart';
import 'package:tradie/core/network/api_result.dart';
import 'package:tradie/features/urgentBooking/models/service_model.dart';
import 'package:tradie/features/urgentBooking/models/tradie_recommendation.dart';

import '../test_urgent_booking/fixtures.dart' as fixtures;

// A tiny fake repository implementation lives in test helpers or the fixture
// location in `lib` (we use handlers injected below in the original test).

class FakeUrgentBookingRepository extends UrgentBookingRepository {
  Future<ApiResult<List<ServiceModel>>> Function({String? status, int page})?
  fetchServicesHandler;

  Future<ApiResult<ServiceModel>> Function({
    required int homeownerId,
    required int jobCategoryId,
    required String jobDescription,
    required String location,
    String status,
    int? rating,
  })?
  createServiceHandler;

  Future<ApiResult<TradieRecommendationResponse>> Function(
    int serviceId, {
    Map<String, dynamic>? queryParams,
  })?
  getRecommendationsHandler;

  FakeUrgentBookingRepository({
    this.fetchServicesHandler,
    this.createServiceHandler,
    this.getRecommendationsHandler,
  });

  @override
  Future<ApiResult<List<ServiceModel>>> fetchServices({
    String? status,
    int page = 1,
  }) async {
    if (fetchServicesHandler != null) {
      return fetchServicesHandler!(status: status, page: page);
    }
    return const Success([]);
  }

  @override
  Future<ApiResult<ServiceModel>> createService({
    required int homeownerId,
    required int jobCategoryId,
    required String jobDescription,
    required String location,
    String status = 'Pending',
    int? rating,
  }) async {
    if (createServiceHandler != null) {
      return createServiceHandler!(
        homeownerId: homeownerId,
        jobCategoryId: jobCategoryId,
        jobDescription: jobDescription,
        location: location,
        status: status,
        rating: rating,
      );
    }
    return Failure(message: 'No handler');
  }

  @override
  Future<ApiResult<ServiceModel>> getServiceById(int serviceId) async =>
      Failure(message: 'Not implemented');

  @override
  Future<ApiResult<ServiceModel>> updateService(
    int serviceId, {
    int? homeownerId,
    int? jobCategoryId,
    String? jobDescription,
    String? location,
    String? status,
    int? rating,
  }) async => Failure(message: 'Not implemented');

  @override
  Future<ApiResult<void>> deleteService(int serviceId) async =>
      const Success(null);

  @override
  @override
  Future<ApiResult<TradieRecommendationResponse>> getTradieRecommendations(
    int serviceId, {
    Map<String, dynamic>? queryParams,
  }) async {
    if (getRecommendationsHandler != null) {
      return getRecommendationsHandler!(serviceId, queryParams: queryParams);
    }
    return Failure(message: 'No handler');
  }
}

void main() {
  late FakeUrgentBookingRepository fakeRepo;
  late UrgentBookingViewModel viewModel;

  setUp(() {
    fakeRepo = FakeUrgentBookingRepository();
    viewModel = UrgentBookingViewModel(fakeRepo);
  });

  test('fetchServices success updates state with services', () async {
    final service = fixtures.buildService(id: 42);
    fakeRepo.fetchServicesHandler = ({String? status, int page = 1}) async =>
        Success([service]);

    await viewModel.fetchServices();

    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.services, isNotEmpty);
    expect(viewModel.state.services.first.jobId, equals(42));
    expect(viewModel.state.error, isNull);
  });

  test('createService success inserts and selects new service', () async {
    final service = fixtures.buildService(id: 100);
    fakeRepo.createServiceHandler =
        ({
          required homeownerId,
          required jobCategoryId,
          required jobDescription,
          required location,
          status = 'Pending',
          rating,
        }) async {
          return Success(service);
        };

    final result = await viewModel.createService(
      homeownerId: 1,
      jobCategoryId: 1,
      jobDescription: 'desc',
      location: 'loc',
    );

    expect(result, isTrue);
    expect(viewModel.state.isCreatingService, isFalse);
    expect(viewModel.state.services.first.jobId, equals(100));
    expect(viewModel.state.selectedService?.jobId, equals(100));
    expect(viewModel.state.createServiceError, isNull);
  });

  test('getTradieRecommendations success updates recommendations', () async {
    final response = fixtures.buildRecommendations();
    fakeRepo.getRecommendationsHandler =
        (id, {Map<String, dynamic>? queryParams}) async => Success(response);

    await viewModel.getTradieRecommendations(1);

    expect(viewModel.state.isLoadingRecommendations, isFalse);
    expect(viewModel.state.recommendations, isNotEmpty);
    expect(viewModel.state.recommendations.first.name, equals('John'));
    expect(viewModel.state.recommendationsError, isNull);
  });
}
