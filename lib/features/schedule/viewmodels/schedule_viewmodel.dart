import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../services/echo_service.dart';
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

  ScheduleViewModel(this._repository) : super(const ScheduleState()) {
    _initializeRealTimeUpdates();
  }

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

  /// Initialize real-time updates with Laravel Reverb
  void _initializeRealTimeUpdates() {
    try {
      LaravelEchoService.init(
        channel: 'schedules',
        onEvent: _handleRealtimeEvent,
        onConnectionStateChange: (status) {
          if (kDebugMode) {
            print('🔄 Reverb Connection Status: $status');
          }
        },
      );

      if (kDebugMode) {
        print('🚀 Real-time updates initialized for schedules');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize real-time updates: $e');
      }
    }
  }

  /// Handle real-time events from Laravel Reverb
  void _handleRealtimeEvent(Map<String, dynamic> eventData) {
    try {
      final event = eventData['event'] as String?;
      final data = eventData['data'] as Map<String, dynamic>?;

      if (kDebugMode) {
        print('🎯 Received real-time event: $event');
        print('📡 Event data: $data');
      }

      if (event == null || data == null) return;

      switch (event) {
        case 'schedule.created':
        case 'job.created':
          _handleJobCreated(data);
          break;
        case 'schedule.updated':
        case 'job.rescheduled':
          _handleJobRescheduled(data);
          break;
        case 'schedule.cancelled':
        case 'job.cancelled':
          _handleJobCancelled(data);
          break;
        case 'schedule.deleted':
        case 'job.deleted':
          _handleJobDeleted(data);
          break;
        default:
          if (kDebugMode) {
            print('🤷 Unhandled event: $event');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling real-time event: $e');
      }
    }
  }

  /// Handle new job created event
  void _handleJobCreated(Map<String, dynamic> data) {
    try {
      if (kDebugMode) {
        print('✨ New job created - refreshing offers');
      }

      // Refresh the offers list to include the new job
      fetchOffers();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling job created: $e');
      }
    }
  }

  /// Handle job rescheduled event
  void _handleJobRescheduled(Map<String, dynamic> data) {
    try {
      final jobId = data['id'] as int?;
      final startTime = data['start_time'] as String?;
      final endTime = data['end_time'] as String?;

      if (jobId == null) return;

      if (kDebugMode) {
        print('📅 Job $jobId rescheduled - updating local state');
        print('🕐 New start: $startTime');
        print('🕐 New end: $endTime');
      }

      // Update the local state with new times
      final updatedOffers = state.offers.map((offer) {
        if (offer.id == jobId && startTime != null && endTime != null) {
          return OfferModel(
            id: offer.id,
            homeownerId: offer.homeownerId,
            serviceCategoryId: offer.serviceCategoryId,
            tradieId: offer.tradieId,
            jobType: offer.jobType,
            preferredDate: offer.preferredDate,
            frequency: offer.frequency,
            startDate: offer.startDate,
            endDate: offer.endDate,
            title: offer.title,
            jobSize: offer.jobSize,
            description: offer.description,
            address: offer.address,
            latitude: offer.latitude,
            longitude: offer.longitude,
            status: offer.status,
            createdAt: offer.createdAt,
            updatedAt: offer.updatedAt,
            startTime: startTime,
            endTime: endTime,
            rescheduledAt: DateTime.now().toString(),
            photoUrls: offer.photoUrls,
            tradie: offer.tradie,
            category: offer.category,
            photos: offer.photos,
          );
        }
        return offer;
      }).toList();

      state = state.copyWith(offers: updatedOffers);

      if (kDebugMode) {
        print('✅ Local state updated for rescheduled job');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling job rescheduled: $e');
      }
    }
  }

  /// Handle job cancelled event
  void _handleJobCancelled(Map<String, dynamic> data) {
    try {
      final jobId = data['id'] as int?;

      if (jobId == null) return;

      if (kDebugMode) {
        print('❌ Job $jobId cancelled - removing from local state');
      }

      // Remove the cancelled job from local state
      final updatedOffers = state.offers.where((offer) => offer.id != jobId).toList();
      state = state.copyWith(offers: updatedOffers);

      if (kDebugMode) {
        print('✅ Cancelled job removed from local state');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling job cancelled: $e');
      }
    }
  }

  /// Handle job deleted event
  void _handleJobDeleted(Map<String, dynamic> data) {
    try {
      final jobId = data['id'] as int?;

      if (jobId == null) return;

      if (kDebugMode) {
        print('🗑️ Job $jobId deleted - removing from local state');
      }

      // Remove the deleted job from local state
      final updatedOffers = state.offers.where((offer) => offer.id != jobId).toList();
      state = state.copyWith(offers: updatedOffers);

      if (kDebugMode) {
        print('✅ Deleted job removed from local state');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling job deleted: $e');
      }
    }
  }

  @override
  void dispose() {
    // Disconnect from Reverb when viewmodel is disposed
    LaravelEchoService.disconnect();
    super.dispose();
  }
}