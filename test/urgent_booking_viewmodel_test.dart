import 'package:flutter_test/flutter_test.dart';
// Using a lightweight fake repository implementation instead of Mockito to avoid
// matcher issues in this test environment.
import 'package:tradie/features/urgentBooking/viewmodels/urgent_booking_viewmodel.dart';
import 'package:tradie/features/urgentBooking/repositories/urgent_booking_repository.dart';
import 'package:tradie/core/network/api_result.dart';
import 'package:tradie/features/urgentBooking/models/service_model.dart';
import 'package:tradie/features/urgentBooking/models/tradie_recommendation.dart';

import 'package:tradie/features/urgentBooking/test_urgent_booking/fixtures.dart'
    as fixtures;

class FakeUrgentBookingRepository implements UrgentBookingRepository {
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

  Future<ApiResult<TradieRecommendationResponse>> Function(int serviceId)?
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
    return Success([]);
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
  Future<ApiResult<ServiceModel>> getServiceById(int serviceId) async {
    return Failure(message: 'Not implemented');
  }

  @override
  Future<ApiResult<ServiceModel>> updateService(
    int serviceId, {
    int? homeownerId,
    int? jobCategoryId,
    String? jobDescription,
    String? location,
    String? status,
    int? rating,
  }) async {
    return Failure(message: 'Not implemented');
  }

  @override
  Future<ApiResult<void>> deleteService(int serviceId) async {
    return const Success(null);
  }

  @override
  Future<ApiResult<TradieRecommendationResponse>> getTradieRecommendations(
    int serviceId,
  ) async {
    if (getRecommendationsHandler != null) {
      return getRecommendationsHandler!(serviceId);
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
    fakeRepo.fetchServicesHandler = ({String? status, int page = 1}) async {
      return Success([service]);
    };

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
          required int homeownerId,
          required int jobCategoryId,
          required String jobDescription,
          required String location,
          String status = 'Pending',
          int? rating,
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
    fakeRepo.getRecommendationsHandler = (int id) async {
      return Success(response);
    };

    await viewModel.getTradieRecommendations(1);

    expect(viewModel.state.isLoadingRecommendations, isFalse);
    expect(viewModel.state.recommendations, isNotEmpty);
    expect(viewModel.state.recommendations.first.name, equals('John'));
    expect(viewModel.state.recommendationsError, isNull);
  });
}
