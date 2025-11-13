import 'package:dio/dio.dart';
import '../models/review.dart';
import '../models/contractor.dart';

class FeedbackRepository {
  final Dio dio;
  
  // You can replace these with actual API endpoints
  static const String _baseUrl = '/api/feedback';
  static const String _reviewsEndpoint = '$_baseUrl/reviews';
  static const String _contractorsEndpoint = '$_baseUrl/contractors';

  FeedbackRepository({required this.dio});

  /// Fetch all reviews from the API
  Future<List<Review>> fetchAllReviews() async {
    try {
      final response = await dio.get(_reviewsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch reviews');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Fetch all contractors from the API
  Future<List<Contractor>> fetchAllContractors() async {
    try {
      final response = await dio.get(_contractorsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => Contractor.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch contractors');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Submit a new review to the API
  Future<Review> submitReview(Review review) async {
    try {
      final response = await dio.post(
        _reviewsEndpoint,
        data: review.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Review.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to submit review');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete a review by ID
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await dio.delete('$_reviewsEndpoint/$reviewId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete review');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update a review by ID
  Future<Review> updateReview(String reviewId, Review review) async {
    try {
      final response = await dio.put(
        '$_reviewsEndpoint/$reviewId',
        data: review.toJson(),
      );
      if (response.statusCode == 200) {
        return Review.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update review');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Toggle like on a review
  Future<Review> toggleLike(String reviewId) async {
    try {
      final response = await dio.patch('$_reviewsEndpoint/$reviewId/like');
      if (response.statusCode == 200) {
        return Review.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to toggle like');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get filtered reviews by rating
  Future<List<Review>> getReviewsByRating(int rating) async {
    try {
      final response = await dio.get(
        _reviewsEndpoint,
        queryParameters: {'rating': rating},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch filtered reviews');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get contractor by ID
  Future<Contractor> getContractorById(String contractorId) async {
    try {
      final response = await dio.get('$_contractorsEndpoint/$contractorId');
      if (response.statusCode == 200) {
        return Contractor.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch contractor');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle DioException and convert to readable errors
  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
