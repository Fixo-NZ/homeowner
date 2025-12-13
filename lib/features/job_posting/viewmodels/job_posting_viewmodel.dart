import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../../../features/job_posting/models/job_posting_models.dart';
import '../../../features/job_posting/repositories/job_posting_repository.dart';

class JobPostingState {
  final bool isLoading;
  final List<CategoryModel>? categories;
  final List<CategoryModel>? filteredCategories; // ✅ added for search filtering
  final List<ServiceModel>? servicesForCategory;
  final JobPostResponse? createdJob;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final JobPostFormData formData;
  final List<JobListResponse>? jobOffers;
  final JobPostResponse? selectedJobDetail;
  final bool isLoadingJobs;
  final bool isLoadingJobDetail;

  const JobPostingState({
    this.isLoading = false,
    this.categories,
    this.filteredCategories,
    this.servicesForCategory,
    this.createdJob,
    this.error,
    this.fieldErrors,
    this.formData = const JobPostFormData(),
    this.jobOffers,
    this.selectedJobDetail,
    this.isLoadingJobs = false,
    this.isLoadingJobDetail = false,
  });

  JobPostingState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    List<CategoryModel>? filteredCategories,
    List<ServiceModel>? servicesForCategory,
    JobPostResponse? createdJob,
    String? error,
    Map<String, List<String>>? fieldErrors,
    JobPostFormData? formData,
    List<JobListResponse>? jobOffers,
    JobPostResponse? selectedJobDetail,
    bool? isLoadingJobs,
    bool? isLoadingJobDetail,
  }) {
    return JobPostingState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      servicesForCategory: servicesForCategory ?? this.servicesForCategory,
      createdJob: createdJob ?? this.createdJob,
      error: error ?? this.error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      formData: formData ?? this.formData,
      jobOffers: jobOffers ?? this.jobOffers,
      selectedJobDetail: selectedJobDetail ?? this.selectedJobDetail,
      isLoadingJobs: isLoadingJobs ?? this.isLoadingJobs,
      isLoadingJobDetail: isLoadingJobDetail ?? this.isLoadingJobDetail,
    );
  }
}

class JobPostingViewModel extends StateNotifier<JobPostingState> {
  final JobPostingRepository _jobPostingRepository;

  JobPostingViewModel(this._jobPostingRepository)
      : super(const JobPostingState());

  // 🔹 Load all categories
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    final result = await _jobPostingRepository.getCategories();

    switch (result) {
      case Success<List<CategoryModel>>():
        state = state.copyWith(
          isLoading: false,
          categories: result.data,
          filteredCategories: result.data, // ✅ default filtered = all
        );
      case Failure<List<CategoryModel>>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
    }
  }

  // 🔹 Filter categories by search keyword
  void filterCategories(String query) {
    final allCategories = state.categories ?? [];
    if (query.isEmpty) {
      state = state.copyWith(filteredCategories: allCategories);
      return;
    }

    final filtered = allCategories
        .where((c) => c.name.toLowerCase().contains(query.trim().toLowerCase()))
        .toList();

    state = state.copyWith(filteredCategories: filtered);
  }

  // 🔹 Load services by selected category
  Future<void> loadServicesByCategory(int categoryId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      fieldErrors: null,
      servicesForCategory: null,
    );

    final result =
        await _jobPostingRepository.getServicesByCategory(categoryId);

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

  // 🔹 Create job post with photo handling
  Future<bool> createJobPost() async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    try {
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

  // 🔹 Form data updates
  void updateFormData(JobPostFormData newFormData) {
    state = state.copyWith(formData: newFormData);
  }

  void selectCategory(CategoryModel category) {
    final newFormData = state.formData.copyWith(
      selectedCategory: category,
      selectedServices: const [],
    );

    state = state.copyWith(
      formData: newFormData,
      servicesForCategory: null,
    );
  }

  void selectServices(List<ServiceModel> services) {
    final newFormData = state.formData.copyWith(selectedServices: services);
    state = state.copyWith(formData: newFormData);
  }

  void updateJobType(JobType jobType) {
    final newFormData = state.formData.copyWith(jobType: jobType);

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

  // 🔹 Photo management
  void addPhotoFiles(List<File> newPhotos) {
    final currentPhotos = state.formData.photoFiles;
    final updatedPhotos = [...currentPhotos, ...newPhotos];

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

  // 🔹 Utilities
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

  // 🔹 Validation
  bool isFormValid() => state.formData.isFormValid;

  String? getFormValidationError() {
    if (!state.formData.isCategorySelected) return 'Please select a category';
    if (!state.formData.hasServicesSelected)
      return 'Please select at least one service';
    if (!state.formData.isTitleValid) return 'Please enter a job title';
    if (!state.formData.isAddressValid) return 'Please enter an address';
    if (!state.formData.arePhotosValid)
      return 'Please check your photos (max 5, 5MB each)';

    if (state.formData.jobType == JobType.standard &&
        state.formData.preferredDate == null) {
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

  // 🔹 Check if services are loaded for selected category
  bool areServicesLoadedForCurrentCategory() {
    if (state.formData.selectedCategory == null ||
        state.servicesForCategory == null) {
      return false;
    }

    if (state.servicesForCategory!.isEmpty) {
      return false;
    }

    return true;
  }

  Future<void> loadJobOffers() async {
    state = state.copyWith(isLoadingJobs: true, error: null);

    final result = await _jobPostingRepository.getJobOffers();

    switch (result) {
      case Success<List<JobListResponse>>():
        state = state.copyWith(
          isLoadingJobs: false,
          jobOffers: result.data,
        );
      case Failure<List<JobListResponse>>():
        state = state.copyWith(
          isLoadingJobs: false,
          error: result.message,
        );
    }
  }

  Future<void> loadJobOfferDetails(int jobId) async {
    state = state.copyWith(isLoadingJobDetail: true, error: null);

    final result = await _jobPostingRepository.getJobOfferDetails(jobId);

    switch (result) {
      case Success<JobPostResponse>():
        state = state.copyWith(
          isLoadingJobDetail: false,
          selectedJobDetail: result.data,
        );
      case Failure<JobPostResponse>():
        state = state.copyWith(
          isLoadingJobDetail: false,
          error: result.message,
        );
    }
  }

  // Update job post
  Future<bool> updateJobPost(int jobId) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);
    
    try {
      final request = await state.formData.toJobPostRequest();
      final result = await _jobPostingRepository.updateJobOffer(jobId, request);
      
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
        error: 'Failed to update job post: $e',
      );
      return false;
    }
  }

  // Load initial data into form from job edit provider
  void loadInitialDataIntoForm(Map<String, dynamic> data) {
    final newFormData = state.formData.copyWith(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      jobType: data['jobType'] ?? JobType.standard,
      jobSize: data['jobSize'] ?? JobSize.medium,
      preferredDate: data['preferredDate'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      frequency: data['frequency'],
      existingPhotoUrls: List<String>.from(data['photoUrls'] ?? []),
    );
    
    state = state.copyWith(formData: newFormData);
    
    // If category info is available, try to find and select it
    if (data['categoryId'] != null && state.categories != null) {
      final categoryId = int.tryParse(data['categoryId'].toString());
      if (categoryId != null) {
        final category = state.categories!.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => CategoryModel(
            id: categoryId,
            name: data['categoryName'] ?? 'Category',
            description: '',
            icon: '',
            status: 'active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (category != null) {
          // Select the category but don't load services yet
          state = state.copyWith(
            formData: newFormData.copyWith(selectedCategory: category),
          );
        }
      }
    }
  }

void loadExistingJobIntoForm(JobPostFormData formData) {
  state = state.copyWith(formData: formData);
  
  // If we have a category selected, load its services
  if (formData.selectedCategory != null) {
    Future.microtask(() {
      loadServicesByCategory(formData.selectedCategory!.id);
    });
  }
}

  // Delete job offer
  Future<bool> deleteJobOffer(int jobId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _jobPostingRepository.deleteJobOffer(jobId);

    switch (result) {
      case Success<void>():
        // Remove from local list
        final updatedOffers =
            state.jobOffers?.where((job) => job.id != jobId).toList();

        state = state.copyWith(
          isLoading: false,
          jobOffers: updatedOffers,
          selectedJobDetail: null,
        );
        return true;
      case Failure<void>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        return false;
    }
  }

  // Helper to populate form from existing job
  void populateFormFromJob(JobPostResponse job) {
    // This would need to convert JobPostResponse back to JobPostFormData
    // You might need to add a converter method
  }

  void clearSelectedJob() {
    state = state.copyWith(selectedJobDetail: null);
  }
}

// 🔹 Providers
final jobPostingRepositoryProvider = Provider<JobPostingRepository>((ref) {
  return JobPostingRepository();
});

final jobPostingViewModelProvider =
    StateNotifierProvider<JobPostingViewModel, JobPostingState>((ref) {
  final jobPostingRepository = ref.watch(jobPostingRepositoryProvider);
  return JobPostingViewModel(jobPostingRepository);
});