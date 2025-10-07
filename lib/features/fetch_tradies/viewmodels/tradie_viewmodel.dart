import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/features/fetch_tradies/models/tradie_request.dart';
import '../../../core/network/api_result.dart';
import '../models/tradie_model.dart';
//import '../models/tradie_model.dart';
import '../repositories/tradie_repository.dart';

class JobState {
  final bool isLoading;
  final List<TradieRequest> jobs;
  final String? error;

  // recommendations keyed by jobId
  final Map<int, List<TradieModel>> recommendations;
  final bool isLoadingRecommendations;
  final String? recommendationsError;

  const JobState({
    this.isLoading = false,
    this.jobs = const [],
    this.error,
    this.recommendations = const {},
    this.isLoadingRecommendations = false,
    this.recommendationsError,
  });

  JobState copyWith({
    bool? isLoading,
    List<TradieRequest>? jobs,
    String? error,
    Map<int, List<TradieModel>>? recommendations,
    bool? isLoadingRecommendations,
    String? recommendationsError,
  }) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      jobs: jobs ?? this.jobs,
      error: error,
      recommendations: recommendations ?? this.recommendations,
      isLoadingRecommendations:
      isLoadingRecommendations ?? this.isLoadingRecommendations,
      recommendationsError: recommendationsError,
    );
  }
}

// Providers
final tradieRepositoryProvider = Provider<TradieRepository>((ref) {
  return TradieRepository();
});

final tradieViewModelProvider = StateNotifierProvider<TradieViewModel, JobState>((
    ref,
    ) {
  final repo = ref.watch(tradieRepositoryProvider);
  return TradieViewModel(repo);
});

class TradieViewModel extends StateNotifier<JobState> {
  final TradieRepository _repository;
  TradieViewModel(this._repository) : super(const JobState());

  Future<void> fetchJobs({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.fetchJobs(status: status);

    if (result is Success<List<TradieRequest>>) {
      state = state.copyWith(isLoading: false, jobs: result.data, error: null);
    } else if (result is Failure<List<TradieRequest>>) {
      state = state.copyWith(
        isLoading: false,
        error: result.message.isNotEmpty
            ? result.message
            : 'Failed to fetch jobs',
      );
    }
  }

  Future<void> fetchTradieDetailAndRecommendations(int jobId) async {
    // optionally fetch detail first (not required if jobs list contains it)
    // fetch recommendations
    state = state.copyWith(
      isLoadingRecommendations: true,
      recommendationsError: null,
    );
    final result = await _repository.fetchRecommendedTradies(jobId);
    if (result is Success<List<TradieModel>>) {
      final updated = Map<int, List<TradieModel>>.from(state.recommendations);
      updated[jobId] = result.data;
      state = state.copyWith(
        isLoadingRecommendations: false,
        recommendations: updated,
      );
    } else if (result is Failure<List<TradieModel>>) {
      state = state.copyWith(
        isLoadingRecommendations: false,
        recommendationsError: result.message,
      );
    }
  }

  List<TradieModel> recommendationsFor(int jobId) =>
      state.recommendations[jobId] ?? [];
}
