//import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../models/service_model.dart';
import '../models/tradie_recommendation.dart';
import '../models/tradie_filter.dart';
import '../models/urgent_booking_model.dart';
import '../repositories/urgent_booking_repository.dart';


class UrgentBookingState {
  final bool isLoading;
  final List<ServiceModel> services;
  final String? error;
  final ServiceModel? selectedService;
  final bool isLoadingRecommendations;
  final List<TradieRecommendation> recommendations;
  final String? recommendationsError;
  final bool isCreatingService;
  final String? createServiceError;
  final TradieFilter filters;
  // for urgent booking
  final bool isCreatingUrgentBooking;
  final String? createUrgentBookingError;
  final UrgentBookingModel? latestUrgentBooking;


  const UrgentBookingState({
    this.isLoading = false,
    this.services = const [],
    this.error,
    this.selectedService,
    this.isLoadingRecommendations = false,
    this.recommendations = const [],
    this.recommendationsError,
    this.isCreatingService = false,
    this.createServiceError,
    this.filters = const TradieFilter(),
    this.isCreatingUrgentBooking = false,
    this.createUrgentBookingError,
    this.latestUrgentBooking,

  });

  UrgentBookingState copyWith({
    bool? isLoading,
    List<ServiceModel>? services,
    String? error,
    ServiceModel? selectedService,
    bool? isLoadingRecommendations,
    List<TradieRecommendation>? recommendations,
    String? recommendationsError,
    bool? isCreatingService,
    String? createServiceError,
    TradieFilter? filters,
    //urgent booking
    bool? isCreatingUrgentBooking,
    String? createUrgentBookingError,
    UrgentBookingModel? latestUrgentBooking,
  }) {
    return UrgentBookingState(
      isLoading: isLoading ?? this.isLoading,
      services: services ?? this.services,
      error: error,
      selectedService: selectedService ?? this.selectedService,
      isLoadingRecommendations:
          isLoadingRecommendations ?? this.isLoadingRecommendations,
      recommendations: recommendations ?? this.recommendations,
      recommendationsError: recommendationsError,
      isCreatingService: isCreatingService ?? this.isCreatingService,
      createServiceError: createServiceError,
      filters: filters ?? this.filters,
      //urgent booking
      isCreatingUrgentBooking:
      isCreatingUrgentBooking ?? this.isCreatingUrgentBooking,
      createUrgentBookingError:
      createUrgentBookingError ?? this.createUrgentBookingError,
      latestUrgentBooking: latestUrgentBooking ?? this.latestUrgentBooking,
    );
  }
}

// Providers
final urgentBookingRepositoryProvider = Provider<UrgentBookingRepository>((
  ref,
) {
  return UrgentBookingRepository();
});

final urgentBookingViewModelProvider =
    StateNotifierProvider<UrgentBookingViewModel, UrgentBookingState>((ref) {
      final repository = ref.watch(urgentBookingRepositoryProvider);
      return UrgentBookingViewModel(repository);
    });


class UrgentBookingViewModel extends StateNotifier<UrgentBookingState> {
  final UrgentBookingRepository _repository;

  UrgentBookingViewModel(this._repository) : super(const UrgentBookingState());

  // UrgentBooking



  /// Fetch all services
  Future<void> fetchServices({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.fetchServices(status: status);

    if (result is Success<List<ServiceModel>>) {
      state = state.copyWith(
        isLoading: false,
        services: result.data,
        error: null,
      );
    } else if (result is Failure<List<ServiceModel>>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message.isNotEmpty
            ? result.message
            : 'Failed to fetch services',
      );
    }
  }

  /// Create a new service request
  Future<bool> createService({
    required int homeownerId,
    required int jobCategoryId,
    required String jobDescription,
    required String location,
    String status = 'Pending',
    int? rating,
  }) async {
    state = state.copyWith(isCreatingService: true, createServiceError: null);

    final result = await _repository.createService(
      homeownerId: homeownerId,
      jobCategoryId: jobCategoryId,
      jobDescription: jobDescription,
      location: location,
      status: status,
      rating: rating,
    );

    if (result is Success<ServiceModel>) {
      // Add the new service to the list
      final updatedServices = List<ServiceModel>.from(state.services);
      updatedServices.insert(0, result.data);

      state = state.copyWith(
        isCreatingService: false,
        services: updatedServices,
        selectedService: result.data,
        createServiceError: null,
      );
      return true;
    } else if (result is Failure<ServiceModel>) {
      state = state.copyWith(
        isCreatingService: false,
        createServiceError: result.message,
      );
      return false;
    }
    return false;
  }

  /// Get service details by ID
  Future<void> getServiceById(int serviceId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getServiceById(serviceId);

    if (result is Success<ServiceModel>) {
      state = state.copyWith(
        isLoading: false,
        selectedService: result.data,
        error: null,
      );
    } else if (result is Failure<ServiceModel>) {
      state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  /// Update service
  Future<bool> updateService(
    int serviceId, {
    int? homeownerId,
    int? jobCategoryId,
    String? jobDescription,
    String? location,
    String? status,
    int? rating,
  }) async {
    final result = await _repository.updateService(
      serviceId,
      homeownerId: homeownerId,
      jobCategoryId: jobCategoryId,
      jobDescription: jobDescription,
      location: location,
      status: status,
      rating: rating,
    );

    if (result is Success<ServiceModel>) {
      // Update the service in the list
      final updatedServices = state.services.map((service) {
        if (service.id == serviceId) {
          return result.data;
        }
        return service;
      }).toList();

      state = state.copyWith(
        services: updatedServices,
        selectedService: result.data,
      );
      return true;
    }
    return false;
  }

  /// Delete service
  Future<bool> deleteService(int serviceId) async {
    final result = await _repository.deleteService(serviceId);

    if (result is Success<void>) {
      // Remove the service from the list
      final updatedServices = state.services
          .where((service) => service.id != serviceId)
          .toList();

      state = state.copyWith(
        services: updatedServices,
        selectedService: state.selectedService?.id == serviceId
            ? null
            : state.selectedService,
      );
      return true;
    }
    return false;
  }

  /// Get tradie recommendations for a service
  Future<void> getTradieRecommendations(int serviceId) async {
    state = state.copyWith(
      isLoadingRecommendations: true,
      recommendationsError: null,
    );

    final result = await _repository.getTradieRecommendations(
      serviceId,
      queryParams: state.filters.toQueryParams(),
    );

    if (result is Success<TradieRecommendationResponse>) {
      state = state.copyWith(
        isLoadingRecommendations: false,
        recommendations: result.data.recommendations,
        recommendationsError: null,
      );
    } else if (result is Failure<TradieRecommendationResponse>) {
      state = state.copyWith(
        isLoadingRecommendations: false,
        recommendationsError: result.message,
      );
    }
  }

  /// Update filters without applying
  void setFilters(TradieFilter filters) {
    state = state.copyWith(filters: filters);
  }

  /// Reset filters to defaults
  void resetFilters() {
    state = state.copyWith(filters: const TradieFilter());
  }

  /// Apply current filters and refresh recommendations
  Future<void> applyFilters(int serviceId) async {
    await getTradieRecommendations(serviceId);
  }

  /// Set selected service
  void setSelectedService(ServiceModel? service) {
    state = state.copyWith(selectedService: service);
  }

  /// Clear recommendations
  void clearRecommendations() {
    state = state.copyWith(recommendations: [], recommendationsError: null);
  }

  /// Clear errors
  void clearErrors() {
    state = state.copyWith(
      error: null,
      recommendationsError: null,
      createServiceError: null,
    );
  }

  /// Get services by status
  List<ServiceModel> getServicesByStatus(String status) {
    return state.services.where((service) => service.status == status).toList();
  }

  /// Get urgent services (Pending status)
  List<ServiceModel> get urgentServices {
    return getServicesByStatus('Pending');
  }

  /// Get completed services
  List<ServiceModel> get completedServices {
    return getServicesByStatus('Completed');
  }

  /// Get in-progress services
  List<ServiceModel> get inProgressServices {
    return getServicesByStatus('InProgress');
  }

  /// urgent booking

  Future<bool> createUrgentBooking({
    required int jobId,
    String? notes,
    String? priorityLevel,
  }) async {
    state = state.copyWith(
      isCreatingUrgentBooking: true,
      createUrgentBookingError: null,
    );

    final result = await _repository.createUrgentBooking(
      jobId: jobId,
      notes: notes,
      priorityLevel: priorityLevel,
    );

    if (result is Success<UrgentBookingModel>) {
      state = state.copyWith(
        isCreatingUrgentBooking: false,
        latestUrgentBooking: result.data,
      );
      return true;
    } else if (result is Failure<UrgentBookingModel>) {
      state = state.copyWith(
        isCreatingUrgentBooking: false,
        createUrgentBookingError: result.message,
      );
      return false;
    }

    // Fallback (should never hit)
    state = state.copyWith(isCreatingUrgentBooking: false);
    return false;
  }



}
