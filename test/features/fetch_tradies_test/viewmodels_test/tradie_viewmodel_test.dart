import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tradie/core/network/api_result.dart';
import 'package:tradie/features/fetch_tradies/models/tradie_model.dart';
import 'package:tradie/features/fetch_tradies/models/tradie_request.dart';
import 'package:tradie/features/fetch_tradies/viewmodels/tradie_viewmodel.dart';

import '../mocks/tradie_repository_test.mocks.dart';

void main() {
  late MockTradieRepository mockRepo;
  late TradieViewModel viewModel;

  setUp(() {
    mockRepo = MockTradieRepository();
    viewModel = TradieViewModel(mockRepo);
  });

  group('fetchJobs', () {
    test('sets jobs on success', () async {
      final fakeJobs = [
        TradieRequest(
          id: 1,
          title: '',
          description: '',
          status: '',
          jobType: '',
        ),
        TradieRequest(
          id: 2,
          title: '',
          description: '',
          status: '',
          jobType: '',
        ),
      ];
      when(
        mockRepo.fetchJobs(status: anyNamed('status')),
      ).thenAnswer((_) async => Success(fakeJobs));

      await viewModel.fetchJobs(status: 'active');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.jobs, fakeJobs);
      expect(viewModel.state.error, isNull);
    });

    test('sets error on failure', () async {
      when(
        mockRepo.fetchJobs(status: anyNamed('status')),
      ).thenAnswer((_) async => const Failure(message: 'Server error'));

      await viewModel.fetchJobs(status: 'active');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Server error');
      expect(viewModel.state.jobs, isEmpty);
    });
  });

  group('fetchTradieDetailAndRecommendations', () {
    test('updates recommendations on success', () async {
      final jobId = 1;
      final fakeTradies = [TradieModel(id: 1, name: 'Test Tradie')];
      when(
        mockRepo.fetchRecommendedTradies(jobId),
      ).thenAnswer((_) async => Success(fakeTradies));

      await viewModel.fetchTradieDetailAndRecommendations(jobId);

      expect(viewModel.state.isLoadingRecommendations, false);
      expect(viewModel.state.recommendations[jobId], fakeTradies);
      expect(viewModel.state.recommendationsError, isNull);
    });

    test('sets error on failure', () async {
      final jobId = 1;
      when(
        mockRepo.fetchRecommendedTradies(jobId),
      ).thenAnswer((_) async => const Failure(message: 'Network issue'));

      await viewModel.fetchTradieDetailAndRecommendations(jobId);

      expect(viewModel.state.isLoadingRecommendations, false);
      expect(viewModel.state.recommendationsError, 'Network issue');
      expect(viewModel.state.recommendations[jobId], isNull);
    });
  });
}
