import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../repositories/job_applicant_repository.dart';
import '../models/job_applicant_models.dart';

class JobApplicantState {
  final bool isLoading;
  final List<JobApplicant>? applicants;
  final String? error;
  final bool isAccepting;
  final bool isRejecting;
  final bool isCompleting;
  final int? selectedApplicantId;

  const JobApplicantState({
    this.isLoading = false,
    this.applicants,
    this.error,
    this.isAccepting = false,
    this.isRejecting = false,
    this.isCompleting = false,
    this.selectedApplicantId,
  });

  JobApplicantState copyWith({
    bool? isLoading,
    List<JobApplicant>? applicants,
    String? error,
    bool? isAccepting,
    bool? isRejecting,
    bool? isCompleting,
    int? selectedApplicantId,
  }) {
    return JobApplicantState(
      isLoading: isLoading ?? this.isLoading,
      applicants: applicants ?? this.applicants,
      error: error ?? this.error,
      isAccepting: isAccepting ?? this.isAccepting,
      isRejecting: isRejecting ?? this.isRejecting,
      isCompleting: isCompleting ?? this.isCompleting,
      selectedApplicantId: selectedApplicantId ?? this.selectedApplicantId,
    );
  }
}

class JobApplicantViewModel extends StateNotifier<JobApplicantState> {
  final JobApplicantRepository _repository;

  JobApplicantViewModel(this._repository)
      : super(const JobApplicantState());

  // Load applicants for a job
  Future<void> loadApplicants(int jobId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.getJobApplicants(jobId);
    
    switch (result) {
      case Success<List<JobApplicant>>():
        state = state.copyWith(
          isLoading: false,
          applicants: result.data,
        );
      case Failure<List<JobApplicant>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
    }
  }

  // Accept an applicant
  Future<bool> acceptApplicant(int jobId, int applicationId) async {
    state = state.copyWith(isAccepting: true, error: null);
    
    final result = await _repository.acceptApplicant(jobId, applicationId);
    
    switch (result) {
      case Success<ApplicantActionResponse>():
        // Update applicant status locally
        final updatedApplicants = state.applicants?.map((app) {
          if (app.id == applicationId) {
            return app.copyWith(status: 'accepted');
          } else if (app.isPending) {
            return app.copyWith(status: 'rejected');
          }
          return app;
        }).toList();
        
        state = state.copyWith(
          isAccepting: false,
          applicants: updatedApplicants,
        );
        return true;
      case Failure<ApplicantActionResponse>():
        state = state.copyWith(
          isAccepting: false,
          error: result.message,
        );
        return false;
    }
  }

  // Reject an applicant
  Future<bool> rejectApplicant(int jobId, int applicationId) async {
    state = state.copyWith(isRejecting: true, error: null);
    
    final result = await _repository.rejectApplicant(jobId, applicationId);
    
    switch (result) {
      case Success<ApplicantActionResponse>():
        // Update applicant status locally
        final updatedApplicants = state.applicants?.map((app) {
          if (app.id == applicationId) {
            return app.copyWith(status: 'rejected');
          }
          return app;
        }).toList();
        
        state = state.copyWith(
          isRejecting: false,
          applicants: updatedApplicants,
        );
        return true;
      case Failure<ApplicantActionResponse>():
        state = state.copyWith(
          isRejecting: false,
          error: result.message,
        );
        return false;
    }
  }

  // Complete job
  Future<bool> completeJob(int jobId) async {
    state = state.copyWith(isCompleting: true, error: null);
    
    final result = await _repository.completeJob(jobId);
    
    switch (result) {
      case Success<ApplicantActionResponse>():
        state = state.copyWith(isCompleting: false);
        return true;
      case Failure<ApplicantActionResponse>():
        state = state.copyWith(
          isCompleting: false,
          error: result.message,
        );
        return false;
    }
  }

  void selectApplicant(int? applicantId) {
    state = state.copyWith(selectedApplicantId: applicantId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final jobApplicantRepositoryProvider = Provider<JobApplicantRepository>((ref) {
  return JobApplicantRepository();
});

final jobApplicantViewModelProvider =
    StateNotifierProvider<JobApplicantViewModel, JobApplicantState>((ref) {
  final repository = ref.watch(jobApplicantRepositoryProvider);
  return JobApplicantViewModel(repository);
});