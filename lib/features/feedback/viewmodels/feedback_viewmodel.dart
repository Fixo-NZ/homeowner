import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../models/contractor.dart';
import '../repositories/feedback_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class FeedbackState {
  final String activeTab;
  final bool isReviewSubmitted;
  final String selectedFilter;
  final bool showUsername;
  final List<String> selectedMedia;
  final String? selectedContractor;
  final Contractor? viewingContractor;
  final List<String> reviewedContractors;
  final String commentValue;
  final int overallRating;
  final int qualityRating;
  final int responseRating;
  final bool isLoading;
  final String? errorMessage;
  final List<Review> allReviews;
  final List<Contractor> contractors;

  FeedbackState({
    this.activeTab = 'reviews',
    this.isReviewSubmitted = false,
    this.selectedFilter = 'All',
    this.showUsername = false,
    this.selectedMedia = const [],
    this.selectedContractor,
    this.viewingContractor,
    this.reviewedContractors = const [],
    this.commentValue = '',
    this.overallRating = 0,
    this.qualityRating = 0,
    this.responseRating = 0,
    this.isLoading = false,
    this.errorMessage,
    this.allReviews = const [],
    this.contractors = const [],
  });

  FeedbackState copyWith({
    String? activeTab,
    bool? isReviewSubmitted,
    String? selectedFilter,
    bool? showUsername,
    List<String>? selectedMedia,
    String? selectedContractor,
    Contractor? viewingContractor,
    List<String>? reviewedContractors,
    String? commentValue,
    int? overallRating,
    int? qualityRating,
    int? responseRating,
    bool? isLoading,
    String? errorMessage,
    List<Review>? allReviews,
    List<Contractor>? contractors,
  }) {
    return FeedbackState(
      activeTab: activeTab ?? this.activeTab,
      isReviewSubmitted: isReviewSubmitted ?? this.isReviewSubmitted,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      showUsername: showUsername ?? this.showUsername,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      selectedContractor: selectedContractor ?? this.selectedContractor,
      viewingContractor: viewingContractor ?? this.viewingContractor,
      reviewedContractors: reviewedContractors ?? this.reviewedContractors,
      commentValue: commentValue ?? this.commentValue,
      overallRating: overallRating ?? this.overallRating,
      qualityRating: qualityRating ?? this.qualityRating,
      responseRating: responseRating ?? this.responseRating,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      allReviews: allReviews ?? this.allReviews,
      contractors: contractors ?? this.contractors,
    );
  }
}

class FeedbackViewModel extends StateNotifier<FeedbackState> {
  final FeedbackRepository repository;
  final String? currentUserId;
  final String? currentUserName;

  FeedbackViewModel({required this.repository, this.currentUserId, this.currentUserName})
      : super(FeedbackState()) {
    // start background sync for pending reviews
    repository.startAutoSync();
    // Load reviews and contractors from API on init
    _loadInitialData();
  }

  /// Build a Review object from the current form state
  Review get newReview {
    final avgRating = ((state.overallRating + state.qualityRating + state.responseRating) / 3).round();
    return Review(
      id: null,
      name: state.showUsername ? (currentUserName ?? 'You') : 'Anonymous',
      rating: avgRating,
      date: DateTime.now(),
      comment: state.commentValue,
      likes: 0,
      isLiked: false,
      isEdited: false,
      mediaFiles: state.selectedMedia,
      isSynced: false,
      contractorId: state.selectedContractor,
      homeownerId: currentUserId,
    );
  }

  /// Load reviews and contractors from the API
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final reviews = await repository.fetchAllReviews();
      final contractors = await repository.fetchAllContractors();
      state = state.copyWith(
        allReviews: reviews,
        contractors: contractors,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load reviews: ${e.toString()}',
      );
    }
  }

  /// Refresh reviews from the server (manual pull-to-refresh)
  Future<void> refreshReviews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final reviews = await repository.fetchAllReviews();
      state = state.copyWith(
        allReviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh reviews: ${e.toString()}',
      );
    }
  }

  List<Review> get filteredReviews {
    if (state.selectedFilter == 'All') return state.allReviews;
    final rating = int.parse(state.selectedFilter.split(' ')[0]);
    return state.allReviews.where((r) => r.rating == rating).toList();
  }

  Map<int, int> get ratingCounts {
    final counts = <int, int>{};
    for (var review in state.allReviews) {
      counts[review.rating] = (counts[review.rating] ?? 0) + 1;
    }
    return counts;
  }

  double get averageRating {
    if (state.allReviews.isEmpty) return 0;
    return state.allReviews.map((r) => r.rating).reduce((a, b) => a + b) /
        state.allReviews.length;
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab, isReviewSubmitted: false);
  }

  void setComment(String val) {
    state = state.copyWith(commentValue: val);
  }

  void setOverallRating(int val) {
    state = state.copyWith(overallRating: val);
  }

  void setQualityRating(int val) {
    state = state.copyWith(qualityRating: val);
  }

  void setResponseRating(int val) {
    state = state.copyWith(responseRating: val);
  }

  void toggleUsername(bool val) {
    state = state.copyWith(showUsername: val);
  }

  void selectContractor(String? id) {
    state = state.copyWith(selectedContractor: id);
  }

  void handleContractorClick(String contractorId) {
    final contractor = state.contractors.firstWhere((c) => c.id == contractorId);
    state = state.copyWith(
      viewingContractor: contractor,
      selectedContractor: contractorId,
    );
  }

  void resetForm() {
    state = state.copyWith(
      commentValue: '',
      overallRating: 0,
      qualityRating: 0,
      responseRating: 0,
      showUsername: false,
      selectedMedia: [],
      errorMessage: null,
    );
  }

  Future<void> toggleLike(int index) async {
    if (index < 0 || index >= state.allReviews.length) return;
    final reviews = [...state.allReviews];
    final target = reviews[index];
    try {
      final id = target.id ?? target.date.toIso8601String();
      final updated = await repository.toggleLike(id);
      // replace in list
      reviews[index] = updated;
      state = state.copyWith(allReviews: reviews);
    } catch (e) {
      // fallback: optimistic local toggle
      target.isLiked = !target.isLiked;
      target.likes += target.isLiked ? 1 : -1;
      reviews[index] = target;
      state = state.copyWith(allReviews: reviews);
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteReview(int index) async {
    if (index < 0 || index >= state.allReviews.length) return;
    final reviews = [...state.allReviews];
    final target = reviews[index];
    final id = target.id ?? target.date.toIso8601String();
    try {
      await repository.deleteReview(id);
      reviews.removeAt(index);
      state = state.copyWith(allReviews: reviews);
    } catch (e) {
      // fallback: remove locally and report error
      reviews.removeAt(index);
      state = state.copyWith(allReviews: reviews, errorMessage: e.toString());
    }
  }

  void removeMedia(int index) {
    if (index >= 0 && index < state.selectedMedia.length) {
      final media = [...state.selectedMedia];
      media.removeAt(index);
      state = state.copyWith(selectedMedia: media);
    }
  }

  Future<void> submitReview() async {
    if (state.overallRating == 0 ||
        state.qualityRating == 0 ||
        state.responseRating == 0) {
      state = state.copyWith(errorMessage: 'Please rate all categories');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final avgRating =
          ((state.overallRating + state.qualityRating + state.responseRating) /
                  3)
              .round();

      // Submit to server; repository returns the saved review (with id)
      final saved = await repository.submitReview(newReview);

      final reviews = [saved, ...state.allReviews];
      final reviewedContractors = [...state.reviewedContractors];

      if (state.selectedContractor != null &&
          !reviewedContractors.contains(state.selectedContractor)) {
        reviewedContractors.add(state.selectedContractor!);
      }

      state = state.copyWith(
        allReviews: reviews,
        isReviewSubmitted: true,
        isLoading: false,
        reviewedContractors: reviewedContractors,
        commentValue: '',
        overallRating: 0,
        qualityRating: 0,
        responseRating: 0,
        showUsername: false,
        selectedMedia: [],
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  void backFromContractor() {
    state = state.copyWith(
      viewingContractor: null,
      selectedContractor: null,
    );
    resetForm();
  }

  @override
  void dispose() {
    try {
      repository.stopAutoSync();
    } catch (_) {}
    super.dispose();
  }

  void submitAnother() {
    state = state.copyWith(isReviewSubmitted: false);
    resetForm();
  }

  Future<void> viewAllReviews() async {
    state = state.copyWith(
      viewingContractor: null,
      isReviewSubmitted: false,
      activeTab: 'reviews',
    );
    // Reload reviews from server to show the newly submitted review
    await loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final reviews = await repository.fetchAllReviews();
      state = state.copyWith(allReviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadContractors() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final contractors = await repository.fetchAllContractors();
      state = state.copyWith(contractors: contractors, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }
}

final feedbackViewModelProvider =
    StateNotifierProvider<FeedbackViewModel, FeedbackState>((ref) {
  final repository = ref.watch(feedbackRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  final currentUserId = authState.user?.id?.toString();
  final currentUserName = authState.user?.fullName;
  return FeedbackViewModel(repository: repository, currentUserId: currentUserId, currentUserName: currentUserName);
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final dio = DioClient.instance.dio;
  // Build feedback base URL from Dio baseUrl (e.g. http://127.0.0.1:8000/api -> http://127.0.0.1:8000/api/feedback)
  final dioBase = dio.options.baseUrl ?? '';
  final cleaned = dioBase.endsWith('/') ? dioBase.substring(0, dioBase.length - 1) : dioBase;
  final feedbackBase = '$cleaned/feedback';
  return FeedbackRepository(dio: dio, serverBaseUrl: feedbackBase);
});
