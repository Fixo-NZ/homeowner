import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tradie/features/feedback/repositories/feedback_repository.dart';
import 'package:tradie/features/feedback/models/review.dart';
import 'package:tradie/features/feedback/models/contractor.dart';

@GenerateMocks([Dio])
import 'feedback_repository_test.mocks.dart';

void main() {
  late FeedbackRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = FeedbackRepository(
      dio: mockDio,
      serverBaseUrl: 'http://localhost:8000/api/feedback',
    );
  });

  group('FeedbackRepository - fetchAllReviews', () {
    test('should fetch reviews successfully', () async {
      final mockResponse = Response(
        data: {
          'data': [
            {
              'id': '1',
              'name': 'John Doe',
              'rating': 5,
              'date': '2025-12-02T10:00:00.000Z',
              'comment': 'Great service!',
              'likes': 10,
              'isLiked': false,
              'mediaPaths': [],
              'contractorId': '1',
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

      final reviews = await repository.fetchAllReviews();

      expect(reviews.length, 1);
      expect(reviews[0].name, 'John Doe');
      expect(reviews[0].rating, 5);
      verify(mockDio.get('http://localhost:8000/api/feedback/reviews')).called(1);
    });

    test('should throw exception on failed fetch', () async {
      when(mockDio.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.fetchAllReviews(),
        throwsA(isA<String>()),
      );
    });
  });

  group('FeedbackRepository - submitReview', () {
    test('should submit review successfully', () async {
      final review = Review(
        name: 'Test User',
        rating: 4,
        date: DateTime(2025, 12, 2),
        comment: 'Good work',
        likes: 0,
      );

      final mockResponse = Response(
        data: {
          'data': {
            'id': '123',
            'name': 'Test User',
            'rating': 4,
            'date': '2025-12-02T00:00:00.000Z',
            'comment': 'Good work',
            'likes': 0,
            'isLiked': false,
            'mediaPaths': [],
            'contractorId': null,
          }
        },
        statusCode: 201,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.submitReview(review);

      expect(result.id, '123');
      expect(result.name, 'Test User');
      expect(result.rating, 4);
      verify(mockDio.post(
        'http://localhost:8000/api/feedback/reviews',
        data: anyNamed('data'),
      )).called(1);
    });
  });

  group('FeedbackRepository - deleteReview', () {
    test('should delete review successfully', () async {
      final mockResponse = Response(
        statusCode: 204,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.delete(any)).thenAnswer((_) async => mockResponse);

      await repository.deleteReview('123');

      verify(mockDio.delete('http://localhost:8000/api/feedback/reviews/123'))
          .called(1);
    });
  });

  group('FeedbackRepository - toggleLike', () {
    test('should toggle like successfully', () async {
      final mockResponse = Response(
        data: {
          'data': {
            'id': '123',
            'name': 'John Doe',
            'rating': 5,
            'date': '2025-12-02T10:00:00.000Z',
            'comment': 'Great!',
            'likes': 11,
            'isLiked': true,
            'mediaPaths': [],
            'contractorId': '1',
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.patch(any)).thenAnswer((_) async => mockResponse);

      final result = await repository.toggleLike('123');

      expect(result.likes, 11);
      expect(result.isLiked, true);
      verify(mockDio.patch('http://localhost:8000/api/feedback/reviews/123/like'))
          .called(1);
    });
  });

  group('FeedbackRepository - fetchAllContractors', () {
    test('should fetch contractors successfully', () async {
      final mockResponse = Response(
        data: {
          'data': [
            {
              'id': '1',
              'name': 'John Builder',
              'specialty': 'Carpenter',
              'avatar': 'JB',
              'rating': 4.8,
              'completedJobs': 150,
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

      final contractors = await repository.fetchAllContractors();

      expect(contractors.length, 1);
      expect(contractors[0].name, 'John Builder');
      expect(contractors[0].specialty, 'Carpenter');
    });
  });
}
