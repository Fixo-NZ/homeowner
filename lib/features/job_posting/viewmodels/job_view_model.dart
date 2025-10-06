import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../models/job_category_model.dart';
import '../repositories/job_repository.dart';

class JobState {
  final bool isLoading;
  final List<JobCategory> categories;
  final String? error;

  const JobState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
  });

  JobState copyWith({
    bool? isLoading,
    List<JobCategory>? categories,
    String? error,
  }) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}

class JobViewModel extends StateNotifier<JobState> {
  final JobRepository _repository;

  JobViewModel(this._repository) : super(const JobState());

  Future<void> loadCategoriesWithServices() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getJobCategories();

    switch (result) {
      case Success<List<JobCategory>>():
        state = state.copyWith(isLoading: false, categories: result.data);
      case Failure<List<JobCategory>>():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

final jobViewModelProvider =
    StateNotifierProvider<JobViewModel, JobState>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return JobViewModel(repo);
});
