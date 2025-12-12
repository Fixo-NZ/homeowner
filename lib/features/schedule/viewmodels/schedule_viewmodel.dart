import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../models/schedule_model.dart';
import '../repositories/schedule_repository.dart';

// Provider for the repository
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

// Provider for the viewmodel
final scheduleViewModelProvider =
    StateNotifierProvider<ScheduleViewModel, ScheduleState>((ref) {
  final repository = ref.read(scheduleRepositoryProvider);
  return ScheduleViewModel(repository);
});

// State class
class ScheduleState {
  final List<OfferModel> offers;
  final OfferModel? selectedOffer;
  final bool isLoading;
  final String? error;
  final bool isUpdating;

  const ScheduleState({
    this.offers = const [],
    this.selectedOffer,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  ScheduleState copyWith({
    List<OfferModel>? offers,
    OfferModel? selectedOffer,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return ScheduleState(
      offers: offers ?? this.offers,
      selectedOffer: selectedOffer ?? this.selectedOffer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  // Filter offers by status
  List<OfferModel> get urgentOffers =>
      offers.where((offer) => offer.status == 'urgent').toList();

  List<OfferModel> get inProgressOffers =>
      offers.where((offer) => offer.status == 'in_progress').toList();

  List<OfferModel> get completedOffers =>
      offers.where((offer) => offer.status == 'completed').toList();
}

// ViewModel
class ScheduleViewModel extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleViewModel(this._repository) : super(const ScheduleState());

  Future<void> fetchOffers({String? status}) async {
    print('🚀 ScheduleViewModel: Starting fetchOffers with status: $status');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.fetchOffers(status: status);

      if (result is Success<List<OfferModel>>) {
        print('✅ ScheduleViewModel: Successfully fetched ${result.data.length} offers');
        state = state.copyWith(
          offers: result.data,
          isLoading: false,
        );
      } else if (result is Failure<List<OfferModel>>) {
        print('❌ ScheduleViewModel: Failed to fetch offers: ${result.message}');
        state = state.copyWith(
          error: result.message,
          isLoading: false,
        );
      }
    } catch (e, stackTrace) {
      print('💥 ScheduleViewModel: Unexpected error in fetchOffers: $e');
      print('📍 Stack trace: $stackTrace');
      state = state.copyWith(
        error: 'Unexpected error: $e',
        isLoading: false,
      );
    }
  }

  Future<void> fetchOfferDetail(int offerId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.fetchOfferDetail(offerId);

    if (result is Success<OfferModel>) {
      state = state.copyWith(
        selectedOffer: result.data,
        isLoading: false,
      );
    } else if (result is Failure<OfferModel>) {
      state = state.copyWith(
        error: result.message,
        isLoading: false,
      );
    }
  }

  Future<void> updateOfferStatus({
    required int offerId,
    required String status,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);

    final result = await _repository.updateOfferStatus(
      offerId: offerId,
      status: status,
    );

    if (result is Success<OfferModel>) {
      // Update the offer in the list
      final updatedOffers = state.offers.map((offer) {
        return offer.id == offerId ? result.data : offer;
      }).toList();

      state = state.copyWith(
        offers: updatedOffers,
        selectedOffer: result.data,
        isUpdating: false,
      );
    } else if (result is Failure<OfferModel>) {
      state = state.copyWith(
        error: result.message,
        isUpdating: false,
      );
    }
  }

  Future<void> rescheduleEvent({
    required int id,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    if (kDebugMode) {
      print('🔄 Rescheduling event $id');
      print('📅 Start: ${startTime.toIso8601String()}');
      print('📅 End: ${endTime.toIso8601String()}');
    }

    final result = await _repository.rescheduleEvent(
      id: id,
      startTime: startTime,
      endTime: endTime,
    );

    switch (result) {
      case Success<OfferModel>():
        // Update the existing offer with new times
        final updatedList = state.offers.map((event) {
          if (event.id == id) {
            // Create a new offer with updated times
            return OfferModel(
              id: event.id,
              homeownerId: event.homeownerId,
              serviceCategoryId: event.serviceCategoryId,
              tradieId: event.tradieId,
              jobType: event.jobType,
              preferredDate: event.preferredDate,
              frequency: event.frequency,
              startDate: event.startDate,
              endDate: event.endDate,
              title: event.title,
              jobSize: event.jobSize,
              description: event.description,
              address: event.address,
              latitude: event.latitude,
              longitude: event.longitude,
              status: event.status,
              createdAt: event.createdAt,
              updatedAt: event.updatedAt,
              startTime: startTime.toString().replaceFirst('T', ' ').substring(0, 19),
              endTime: endTime.toString().replaceFirst('T', ' ').substring(0, 19),
              rescheduledAt: DateTime.now().toString(),
              photoUrls: event.photoUrls,
              tradie: event.tradie,
              category: event.category,
              photos: event.photos,
            );
          }
          return event;
        }).toList();
        
        state = state.copyWith(
          isLoading: false, 
          offers: updatedList
        );
        
        if (kDebugMode) {
          print('✅ Schedule rescheduled successfully: $id');
          print('📅 New start: $startTime');
          print('📅 New end: $endTime');
        }
        
      case Failure<OfferModel>():
        state = state.copyWith(
          isLoading: false, 
          error: result.message
        );
        
        if (kDebugMode) {
          print('❌ Failed to reschedule: ${result.message}');
        }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedOffer() {
    state = state.copyWith(selectedOffer: null);
  }

  void refreshOffers() {
    fetchOffers();
  }

  Future<void> cancelEvent(int id) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await _repository.cancelSchedule(id);
      
      // DEBUG: log the result
      if (kDebugMode) {
        print('🔴 CANCEL RESPONSE: $result');
      }
      
      // Check if the API call was successful
      if (result is Success<bool>) {
        // If successful, remove locally
        final updatedList = state.offers.where((event) => event.id != id).toList();
        state = state.copyWith(isLoading: false, offers: updatedList);
        
        if (kDebugMode) {
          print('🟢 FINAL state.offers: ${state.offers.map((e) => e.id).toList()}');
        }
      } else if (result is Failure<bool>) {
        // If failed, show error
        state = state.copyWith(isLoading: false, error: result.message);
        if (kDebugMode) {
          print('❌ CANCEL FAILED: ${result.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ DELETE FAILED: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}