import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/core/network/api_result.dart';
import 'package:tradie/features/fetch_tradies/models/tradie_model.dart';
import 'package:tradie/features/fetch_tradies/models/tradie_request.dart';
import 'package:tradie/features/fetch_tradies/viewmodels/tradie_viewmodel.dart';
import 'package:tradie/features/fetch_tradies/repositories/tradie_repository.dart';

class FakeTradieRepository extends TradieRepository {
  ApiResult<List<TradieRequest>>? jobsResult;
  ApiResult<List<TradieModel>>? recommendedResult;

  FakeTradieRepository();

  @override
  Future<ApiResult<List<TradieRequest>>> fetchJobs({
    String? status,
    int page = 1,
  }) async {
    return jobsResult ?? Success<List<TradieRequest>>([]);
  }

  @override
  Future<ApiResult<List<TradieModel>>> fetchRecommendedTradies(
    int jobId,
  ) async {
    return recommendedResult ?? Success<List<TradieModel>>([]);
  }
}

void main() {
  late FakeTradieRepository repo;
  late TradieViewModel viewModel;

  setUp(() {
    repo = FakeTradieRepository();
    viewModel = TradieViewModel(repo);
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
      repo.jobsResult = Success(fakeJobs);

      await viewModel.fetchJobs(status: 'active');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.jobs, fakeJobs);
      expect(viewModel.state.error, isNull);
    });

    test('sets error on failure', () async {
      repo.jobsResult = const Failure(message: 'Server error');

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
      repo.recommendedResult = Success(fakeTradies);

      await viewModel.fetchTradieDetailAndRecommendations(jobId);

      expect(viewModel.state.isLoadingRecommendations, false);
      expect(viewModel.state.recommendations[jobId], fakeTradies);
      expect(viewModel.state.recommendationsError, isNull);
    });

    test('sets error on failure', () async {
      final jobId = 1;
      repo.recommendedResult = const Failure(message: 'Network issue');

      await viewModel.fetchTradieDetailAndRecommendations(jobId);

      expect(viewModel.state.isLoadingRecommendations, false);
      expect(viewModel.state.recommendationsError, 'Network issue');
      expect(viewModel.state.recommendations[jobId], isNull);
    });
  });
}
