import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../models/contractor.dart';
import '../repositories/feedback_repository.dart';
import '../../../core/network/dio_client.dart';

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

  FeedbackViewModel({required this.repository})
      : super(FeedbackState(
          contractors: [
            Contractor(
              id: '1',
              name: 'Robert Wilson',
              specialty: 'Plumber',
              avatar: 'RW',
              rating: 4.9,
              completedJobs: 127,
            ),
            Contractor(
              id: '2',
              name: 'Maria Garcia',
              specialty: 'Electrician',
              avatar: 'MG',
              rating: 4.8,
              completedJobs: 95,
            ),
            Contractor(
              id: '3',
              name: 'David Chen',
              specialty: 'Carpenter',
              avatar: 'DC',
              rating: 5.0,
              completedJobs: 143,
            ),
            Contractor(
              id: '4',
              name: 'Jessica Brown',
              specialty: 'HVAC Technician',
              avatar: 'JB',
              rating: 4.7,
              completedJobs: 88,
            ),
            Contractor(
              id: '5',
              name: 'Michael Johnson',
              specialty: 'General Contractor',
              avatar: 'MJ',
              rating: 4.9,
              completedJobs: 156,
            ),
          ],
          allReviews: [
            Review(
              name: 'John Martinez',
              rating: 5,
              date: DateTime.now().subtract(const Duration(days: 240)),
              comment:
                  'Excellent service! The plumber arrived on time and fixed my leaking pipes efficiently. Very professional and cleaned up after the work.',
              likes: 12,
              contractorId: '1',
              mediaFiles: [],
            ),
            Review(
              name: 'Sarah Chen',
              rating: 4,
              date: DateTime.now().subtract(const Duration(days: 180)),
              comment:
                  'Good quality work overall. The technician was knowledgeable and explained everything clearly.',
              likes: 8,
              contractorId: '2',
              mediaFiles: [],
            ),
            Review(
              name: 'Mike Thompson',
              rating: 5,
              date: DateTime.now().subtract(const Duration(days: 120)),
              comment:
                  'Outstanding experience from start to finish. They provided a detailed quote upfront and completed the work perfectly.',
              likes: 15,
              contractorId: '3',
              mediaFiles: [],
            ),
          ],
        ));

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

  void toggleLike(int index) {
    if (index >= 0 && index < state.allReviews.length) {
      final reviews = [...state.allReviews];
      reviews[index].isLiked = !reviews[index].isLiked;
      reviews[index].likes += reviews[index].isLiked ? 1 : -1;
      state = state.copyWith(allReviews: reviews);
    }
  }

  void deleteReview(int index) {
    if (index >= 0 && index < state.allReviews.length) {
      final reviews = [...state.allReviews];
      reviews.removeAt(index);
      state = state.copyWith(allReviews: reviews);
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
      final newReview = Review(
        name: state.showUsername ? 'mark_allen_dicoolver' : 'Anonymous User',
        rating: avgRating,
        date: DateTime.now(),
        comment: state.commentValue.trim(),
        likes: 0,
        mediaFiles: [],
        contractorId: state.selectedContractor,
      );

      await repository.submitReview(newReview);

      final reviews = [newReview, ...state.allReviews];
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

  void submitAnother() {
    state = state.copyWith(isReviewSubmitted: false);
    resetForm();
  }

  void viewAllReviews() {
    state = state.copyWith(
      viewingContractor: null,
      isReviewSubmitted: false,
      activeTab: 'reviews',
    );
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
  return FeedbackViewModel(repository: repository);
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final dio = DioClient.instance.dio;
  return FeedbackRepository(dio: dio);
});
