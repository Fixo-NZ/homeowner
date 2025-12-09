import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tradie/features/feedback/viewmodels/feedback_viewmodel.dart';
import 'package:tradie/features/feedback/repositories/feedback_repository.dart';
import 'package:tradie/features/feedback/models/review.dart';
import 'package:tradie/features/feedback/models/contractor.dart';

@GenerateMocks([FeedbackRepository])
import 'feedback_viewmodel_test.mocks.dart';

void main() {
  late FeedbackViewModel viewModel;
  late MockFeedbackRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedbackRepository();
    viewModel = FeedbackViewModel(mockRepository);
  });

  group('FeedbackViewModel - loadReviews', () {
    test('should load reviews successfully', () async {
      final mockReviews = [
        Review(
          id: '1',
          name: 'John Doe',
          rating: 5,
          date: DateTime(2025, 12, 2),
          comment: 'Great!',
          likes: 10,
        ),
        Review(
          id: '2',
          name: 'Jane Smith',
          rating: 4,
          date: DateTime(2025, 12, 1),
          comment: 'Good',
          likes: 5,
        ),
      ];

      when(mockRepository.fetchAllReviews())
          .thenAnswer((_) async => mockReviews);

      await viewModel.loadReviews();

      expect(viewModel.state.allReviews.length, 2);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, null);
      verify(mockRepository.fetchAllReviews()).called(1);
    });

    test('should handle error when loading reviews fails', () async {
      when(mockRepository.fetchAllReviews())
          .thenThrow(Exception('Network error'));

      await viewModel.loadReviews();

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNotNull);
    });
  });

  group('FeedbackViewModel - loadContractors', () {
    test('should load contractors successfully', () async {
      final mockContractors = [
        Contractor(
          id: '1',
          name: 'John Builder',
          specialty: 'Carpenter',
          avatar: 'JB',
          rating: 4.8,
          completedJobs: 150,
        ),
      ];

      when(mockRepository.fetchAllContractors())
          .thenAnswer((_) async => mockContractors);

      await viewModel.loadContractors();

      expect(viewModel.state.allContractors.length, 1);
      expect(viewModel.state.isLoading, false);
      verify(mockRepository.fetchAllContractors()).called(1);
    });
  });

  group('FeedbackViewModel - submitReview', () {
    test('should submit review successfully', () async {
      viewModel.setOverallRating(5);
      viewModel.setQualityRating(5);
      viewModel.setResponseRating(5);
      viewModel.setComment('Excellent service!');

      final savedReview = Review(
        id: '123',
        name: 'Anonymous User',
        rating: 5,
        date: DateTime.now(),
        comment: 'Excellent service!',
        likes: 0,
      );

      when(mockRepository.submitReview(any))
          .thenAnswer((_) async => savedReview);

      await viewModel.submitReview();

      expect(viewModel.state.isReviewSubmitted, true);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.allReviews.length, 1);
      verify(mockRepository.submitReview(any)).called(1);
    });

    test('should not submit review with missing ratings', () async {
      viewModel.setOverallRating(5);
      // Missing quality and response ratings

      await viewModel.submitReview();

      expect(viewModel.state.errorMessage, isNotNull);
      expect(viewModel.state.isReviewSubmitted, false);
      verifyNever(mockRepository.submitReview(any));
    });

    test('should handle error when submit fails', () async {
      viewModel.setOverallRating(5);
      viewModel.setQualityRating(5);
      viewModel.setResponseRating(5);

      when(mockRepository.submitReview(any))
          .thenThrow(Exception('Submit failed'));

      await viewModel.submitReview();

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNotNull);
      expect(viewModel.state.isReviewSubmitted, false);
    });
  });

  group('FeedbackViewModel - deleteReview', () {
    test('should delete review successfully', () async {
      final review = Review(
        id: '123',
        name: 'Test',
        rating: 5,
        date: DateTime.now(),
        comment: 'Test',
        likes: 0,
      );

      viewModel.state = viewModel.state.copyWith(allReviews: [review]);

      when(mockRepository.deleteReview('123')).thenAnswer((_) async => {});

      await viewModel.deleteReview('123');

      expect(viewModel.state.allReviews.length, 0);
      verify(mockRepository.deleteReview('123')).called(1);
    });
  });

  group('FeedbackViewModel - toggleLike', () {
    test('should toggle like successfully', () async {
      final review = Review(
        id: '123',
        name: 'Test',
        rating: 5,
        date: DateTime.now(),
        comment: 'Test',
        likes: 0,
        isLiked: false,
      );

      viewModel.state = viewModel.state.copyWith(allReviews: [review]);

      final updatedReview = Review(
        id: '123',
        name: 'Test',
        rating: 5,
        date: DateTime.now(),
        comment: 'Test',
        likes: 1,
        isLiked: true,
      );

      when(mockRepository.toggleLike('123'))
          .thenAnswer((_) async => updatedReview);

      await viewModel.toggleLike('123');

      expect(viewModel.state.allReviews[0].likes, 1);
      expect(viewModel.state.allReviews[0].isLiked, true);
      verify(mockRepository.toggleLike('123')).called(1);
    });
  });

  group('FeedbackViewModel - state management', () {
    test('should update comment value', () {
      viewModel.setComment('New comment');
      expect(viewModel.state.commentValue, 'New comment');
    });

    test('should update ratings', () {
      viewModel.setOverallRating(5);
      viewModel.setQualityRating(4);
      viewModel.setResponseRating(3);

      expect(viewModel.state.overallRating, 5);
      expect(viewModel.state.qualityRating, 4);
      expect(viewModel.state.responseRating, 3);
    });

    test('should toggle username visibility', () {
      expect(viewModel.state.showUsername, false);
      viewModel.toggleUsername();
      expect(viewModel.state.showUsername, true);
    });

    test('should set active tab', () {
      viewModel.setActiveTab('contractors');
      expect(viewModel.state.activeTab, 'contractors');
    });

    test('should reset form', () {
      viewModel.setComment('Test');
      viewModel.setOverallRating(5);
      viewModel.resetForm();

      expect(viewModel.state.commentValue, '');
      expect(viewModel.state.overallRating, 0);
    });
  });
}
