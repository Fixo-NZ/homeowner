import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../models/contractor.dart';

class FeedbackRepository {
  final Dio dio;
  late final String baseUrl;
  late final String _reviewsEndpoint;
  late final String _contractorsEndpoint;

  /// `serverBaseUrl` should be the full base url, e.g. `http://localhost:8080/api/feedback`
  FeedbackRepository({required this.dio, String? serverBaseUrl}) {
    baseUrl = serverBaseUrl ?? '/api/feedback';
    _reviewsEndpoint = '$baseUrl/reviews';
    _contractorsEndpoint = '$baseUrl/contractors';
  }

  // Local storage keys
  static const String _kLocalReviewsKey = 'feedback_local_reviews';
  static const String _kLocalContractorsKey = 'feedback_local_contractors';
  Timer? _syncTimer;
  Duration _syncInterval = const Duration(seconds: 30);

  /// Helper: load local reviews from SharedPreferences
  Future<List<Review>> _loadLocalReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_kLocalReviewsKey) ?? [];
    return data
        .map((s) => Review.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// Helper: save local reviews to SharedPreferences
  Future<void> _saveLocalReviews(List<Review> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    final data = reviews.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_kLocalReviewsKey, data);
  }

  /// Helper: load local contractors (fallback)
  Future<List<Contractor>> _loadLocalContractors() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_kLocalContractorsKey) ?? [];
    if (data.isEmpty) {
      // Provide a sensible default list if none saved
      return [
        Contractor(id: '1', name: 'Robert Wilson', specialty: 'Plumber', avatar: 'RW', rating: 4.9, completedJobs: 127),
        Contractor(id: '2', name: 'Maria Garcia', specialty: 'Electrician', avatar: 'MG', rating: 4.8, completedJobs: 95),
        Contractor(id: '3', name: 'David Chen', specialty: 'Carpenter', avatar: 'DC', rating: 5.0, completedJobs: 143),
      ];
    }
    return data
        .map((s) => Contractor.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// Helper: save local contractors
  Future<void> _saveLocalContractors(List<Contractor> contractors) async {
    final prefs = await SharedPreferences.getInstance();
    final data = contractors.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_kLocalContractorsKey, data);
  }

  /// Start periodic background sync for pending reviews.
  void startAutoSync({Duration? interval}) {
    _syncTimer?.cancel();
    if (interval != null) _syncInterval = interval;
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      try {
        await syncPendingReviews();
      } catch (_) {}
    });
  }

  /// Stop the periodic background sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Load locally stored reviews that are not yet synced to server
  Future<List<Review>> _loadPendingReviews() async {
    final all = await _loadLocalReviews();
    return all.where((r) => r.id == null || r.isSynced == false).toList();
  }

  /// Attempt to sync pending reviews to server. Returns number of reviews synced.
  Future<int> syncPendingReviews() async {
    final pending = await _loadPendingReviews();
    if (pending.isEmpty) return 0;
    var synced = 0;
    for (final r in pending) {
      try {
        final response = await dio.post(_reviewsEndpoint, data: r.toJson());
        if (response.statusCode == 201 || response.statusCode == 200) {
          final saved = Review.fromJson(response.data['data'] as Map<String, dynamic>);
          // replace local entry with saved one
          final local = await _loadLocalReviews();
          final updated = local.map((lr) {
            if (_matchesId(lr, r.id ?? r.date.toIso8601String())) return saved;
            return lr;
          }).toList();
          await _saveLocalReviews(updated);
          synced++;
        }
      } catch (_) {
        // skip and continue with others
      }
    }
    return synced;
  }

  bool _matchesId(Review r, String id) {
    if (r.id != null && r.id == id) return true;
    return r.date.toIso8601String() == id;
  }

  /// Fetch all reviews from the API
  Future<List<Review>> fetchAllReviews() async {
    try {
      final response = await dio.get(_reviewsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final reviews = data.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList();
        // persist locally for offline fallback
        await _saveLocalReviews(reviews);
        return reviews;
      }
      throw Exception('Failed to fetch reviews');
    } on DioException catch (e) {
      // Network failed — fall back to local persisted reviews
      try {
        return await _loadLocalReviews();
      } catch (_) {
        throw _handleDioException(e);
      }
    }
  }

  /// Fetch all contractors from the API
  Future<List<Contractor>> fetchAllContractors() async {
    try {
      final response = await dio.get(_contractorsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final contractors = data.map((item) => Contractor.fromJson(item as Map<String, dynamic>)).toList();
        await _saveLocalContractors(contractors);
        return contractors;
      }
      throw Exception('Failed to fetch contractors');
    } on DioException catch (e) {
      // Fallback to local contractors
      try {
        return await _loadLocalContractors();
      } catch (_) {
        throw _handleDioException(e);
      }
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
        final saved = Review.fromJson(response.data['data'] as Map<String, dynamic>);
        saved.isSynced = true;
        // ensure local copy includes the newly created review
        try {
          final local = await _loadLocalReviews();
          final updated = [saved, ...local];
          await _saveLocalReviews(updated);
        } catch (_) {}
        return saved;
      }
      throw Exception('Failed to submit review');
    } on DioException catch (e) {
      // Fallback: persist locally and return the review
      try {
        review.isSynced = false;
        final local = await _loadLocalReviews();
        final updated = [review, ...local];
        await _saveLocalReviews(updated);
        return review;
      } catch (_) {
        throw _handleDioException(e);
      }
    }
  }

  /// Delete a review by ID
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await dio.delete('$_reviewsEndpoint/$reviewId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete review');
      }
      // remove from local storage as well
      try {
        final local = await _loadLocalReviews();
        final updated = local.where((r) => !_matchesId(r, reviewId)).toList();
        await _saveLocalReviews(updated);
      } catch (_) {}
    } on DioException catch (e) {
      // Best-effort local deletion if network unavailable
      try {
        final local = await _loadLocalReviews();
        final updated = local.where((r) => !_matchesId(r, reviewId)).toList();
        await _saveLocalReviews(updated);
      } catch (_) {
        throw _handleDioException(e);
      }
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
        final updatedReview = Review.fromJson(response.data['data'] as Map<String, dynamic>);
        // persist update locally
        try {
          final local = await _loadLocalReviews();
          final updated = local.map((r) {
            if (_matchesId(r, reviewId)) return updatedReview;
            return r;
          }).toList();
          await _saveLocalReviews(updated);
        } catch (_) {}
        return updatedReview;
      }
      throw Exception('Failed to update review');
    } on DioException catch (e) {
      // Fallback: update locally
      try {
        final local = await _loadLocalReviews();
        final updated = local.map((r) {
          if (_matchesId(r, reviewId)) return review;
          return r;
        }).toList();
        await _saveLocalReviews(updated);
        return review;
      } catch (_) {
        throw _handleDioException(e);
      }
    }
  }

  /// Toggle like on a review
  Future<Review> toggleLike(String reviewId) async {
    try {
      final response = await dio.patch('$_reviewsEndpoint/$reviewId/like');
      if (response.statusCode == 200) {
        final updatedReview = Review.fromJson(response.data['data'] as Map<String, dynamic>);
        // persist change locally
        try {
          final local = await _loadLocalReviews();
          final updated = local.map((r) {
            if (_matchesId(r, reviewId)) return updatedReview;
            return r;
          }).toList();
          await _saveLocalReviews(updated);
        } catch (_) {}
        return updatedReview;
      }
      throw Exception('Failed to toggle like');
    } on DioException catch (e) {
      // Fallback: toggle in local storage
      try {
        final local = await _loadLocalReviews();
        final updated = local.map((r) {
          if (_matchesId(r, reviewId)) {
            r.isLiked = !r.isLiked;
            r.likes += r.isLiked ? 1 : -1;
          }
          return r;
        }).toList();
        await _saveLocalReviews(updated);
        return updated.firstWhere((r) => _matchesId(r, reviewId));
      } catch (_) {
        throw _handleDioException(e);
      }
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
      // Fallback: filter local
      try {
        final local = await _loadLocalReviews();
        return local.where((r) => r.rating == rating).toList();
      } catch (_) {
        throw _handleDioException(e);
      }
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
      // Fallback: try local contractors
      try {
        final local = await _loadLocalContractors();
        return local.firstWhere((c) => c.id == contractorId);
      } catch (_) {
        throw _handleDioException(e);
      }
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
