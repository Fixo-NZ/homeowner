import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/core/network/api_result.dart';
import 'package:tradie/features/job_posting/models/job_posting_models.dart';
import 'package:tradie/features/job_posting/repositories/job_posting_repository.dart';

class JobPostingState {
  final bool isLoading;
  final List<CategoryModel>? categories;
  final List<ServiceModel>? servicesForCategory;
  final JobPostResponse? createdJob;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final JobPostFormData formData;

  const JobPostingState({
    this.isLoading = false,
    this.categories,
    this.servicesForCategory,
    this.createdJob,
    this.error,
    this.fieldErrors,
    this.formData = const JobPostFormData(),
  });

  JobPostingState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    List<ServiceModel>? servicesForCategory,
    JobPostResponse? createdJob,
    String? error,
    Map<String, List<String>>? fieldErrors,
    JobPostFormData? formData,
  }) {
    return JobPostingState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      servicesForCategory: servicesForCategory ?? this.servicesForCategory,
      createdJob: createdJob ?? this.createdJob,
      error: error ?? this.error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      formData: formData ?? this.formData,
    );
  }
}

class JobPostingViewModel extends StateNotifier<JobPostingState> {
  final JobPostingRepository _jobPostingRepository;

  JobPostingViewModel(this._jobPostingRepository) : super(const JobPostingState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    final result = await _jobPostingRepository.getCategories();

    switch (result) {
      case Success<List<CategoryModel>>():
        state = state.copyWith(
          isLoading: false,
          categories: result.data,
        );
      case Failure<List<CategoryModel>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
    }
  }

  Future<void> loadServicesByCategory(int categoryId) async {
    state = state.copyWith(
      isLoading: true, 
      error: null, 
      fieldErrors: null, 
      servicesForCategory: null
    );

    final result = await _jobPostingRepository.getServicesByCategory(categoryId);

    switch (result) {
      case Success<List<ServiceModel>>():
        state = state.copyWith(
          isLoading: false,
          servicesForCategory: result.data,
        );
      case Failure<List<ServiceModel>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
    }
  }

  // ✅ UPDATED: Create job post with photo handling
  Future<bool> createJobPost() async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    try {
      // Use the form data to create the request
      final request = await state.formData.toJobPostRequest();
      
      final result = await _jobPostingRepository.createJobPost(request);

      switch (result) {
        case Success<JobPostResponse>():
          state = state.copyWith(
            isLoading: false,
            createdJob: result.data,
          );
          return true;
        case Failure<JobPostResponse>():
          state = state.copyWith(
            isLoading: false,
            error: result.message,
            fieldErrors: result.errors,
          );
          return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create job post: $e',
      );
      return false;
    }
  }

  // Form data methods
  void updateFormData(JobPostFormData newFormData) {
    state = state.copyWith(formData: newFormData);
  }

  void selectCategory(CategoryModel category) {
    final newFormData = state.formData.copyWith(
      selectedCategory: category,
      selectedServices: const [], // Clear services when category changes
    );

    state = state.copyWith(
      formData: newFormData,
      servicesForCategory: null, // Clear loaded services
    );
  }

  void selectServices(List<ServiceModel> services) {
    final newFormData = state.formData.copyWith(selectedServices: services);
    state = state.copyWith(formData: newFormData);
  }

  void updateJobType(JobType jobType) {
    final newFormData = state.formData.copyWith(jobType: jobType);

    // If job type is not recurrent, clear recurrent-specific fields
    if (jobType != JobType.recurrent) {
      state = state.copyWith(
        formData: newFormData.copyWith(
          frequency: null,
          startDate: null,
          endDate: null,
        ),
      );
    } else {
      state = state.copyWith(formData: newFormData);
    }
  }

  void updateFrequency(Frequency? frequency) {
    final newFormData = state.formData.copyWith(frequency: frequency);
    state = state.copyWith(formData: newFormData);
  }

  void updateJobSize(JobSize jobSize) {
    final newFormData = state.formData.copyWith(jobSize: jobSize);
    state = state.copyWith(formData: newFormData);
  }

  void updateTitle(String title) {
    final newFormData = state.formData.copyWith(title: title);
    state = state.copyWith(formData: newFormData);
  }

  void updateDescription(String description) {
    final newFormData = state.formData.copyWith(description: description);
    state = state.copyWith(formData: newFormData);
  }

  void updateAddress(String address) {
    final newFormData = state.formData.copyWith(address: address);
    state = state.copyWith(formData: newFormData);
  }

  void updatePreferredDate(DateTime? preferredDate) {
    final newFormData = state.formData.copyWith(preferredDate: preferredDate);
    state = state.copyWith(formData: newFormData);
  }

  void updateStartDate(DateTime? startDate) {
    final newFormData = state.formData.copyWith(startDate: startDate);
    state = state.copyWith(formData: newFormData);
  }

  void updateEndDate(DateTime? endDate) {
    final newFormData = state.formData.copyWith(endDate: endDate);
    state = state.copyWith(formData: newFormData);
  }

  // ✅ NEW: Photo management methods
  void addPhotoFiles(List<File> newPhotos) {
    final currentPhotos = state.formData.photoFiles;
    final updatedPhotos = [...currentPhotos, ...newPhotos];
    
    // Limit to max 5 photos
    if (updatedPhotos.length > 5) {
      updatedPhotos.removeRange(5, updatedPhotos.length);
    }
    
    final newFormData = state.formData.copyWith(photoFiles: updatedPhotos);
    state = state.copyWith(formData: newFormData);
  }

  void removePhoto(int index) {
    final currentPhotos = List<File>.from(state.formData.photoFiles);
    currentPhotos.removeAt(index);
    
    final newFormData = state.formData.copyWith(photoFiles: currentPhotos);
    state = state.copyWith(formData: newFormData);
  }

  void clearAllPhotos() {
    final newFormData = state.formData.copyWith(photoFiles: const []);
    state = state.copyWith(formData: newFormData);
  }

  // Utility methods
  void clearServices() {
    state = state.copyWith(servicesForCategory: null);
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null);
  }

  void clearCreatedJob() {
    state = state.copyWith(createdJob: null);
  }

  void resetForm() {
    state = state.copyWith(
      formData: const JobPostFormData(),
      servicesForCategory: null,
      createdJob: null,
      error: null,
      fieldErrors: null,
    );
  }

  // Validation methods
  bool isFormValid() {
    return state.formData.isFormValid;
  }

  String? getFormValidationError() {
    if (!state.formData.isCategorySelected) {
      return 'Please select a category';
    }

    if (!state.formData.hasServicesSelected) {
      return 'Please select at least one service';
    }

    if (!state.formData.isTitleValid) {
      return 'Please enter a job title';
    }

    if (!state.formData.isAddressValid) {
      return 'Please enter an address';
    }

    if (!state.formData.arePhotosValid) {
      return 'Please check your photos (maximum 5 photos, 5MB each)';
    }

    // Additional validation for job types
    if (state.formData.jobType == JobType.standard && state.formData.preferredDate == null) {
      return 'Please select a preferred date for standard jobs';
    }

    if (state.formData.jobType == JobType.recurrent) {
      if (state.formData.frequency == null) {
        return 'Please select frequency for recurring jobs';
      }
      if (state.formData.startDate == null) {
        return 'Please select a start date for recurring jobs';
      }
    }

    return null;
  }

  // Check if services are loaded for current category
  bool areServicesLoadedForCurrentCategory() {
    return state.servicesForCategory != null &&
        state.formData.selectedCategory != null &&
        state.servicesForCategory!.isNotEmpty &&
        state.servicesForCategory!.first.categoryId == state.formData.selectedCategory!.id;
  }
}

// Providers
final jobPostingRepositoryProvider = Provider<JobPostingRepository>((ref) {
  return JobPostingRepository();
});

final jobPostingViewModelProvider = StateNotifierProvider<JobPostingViewModel, JobPostingState>((ref) {
  final jobPostingRepository = ref.watch(jobPostingRepositoryProvider);
  return JobPostingViewModel(jobPostingRepository);
});