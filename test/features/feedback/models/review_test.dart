import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/features/feedback/models/review.dart';

void main() {
  group('Review Model', () {
    test('should create a Review instance with required fields', () {
      final review = Review(
        name: 'John Doe',
        rating: 5,
        date: DateTime(2025, 12, 2),
        comment: 'Great service!',
        likes: 10,
      );

      expect(review.name, 'John Doe');
      expect(review.rating, 5);
      expect(review.comment, 'Great service!');
      expect(review.likes, 10);
      expect(review.isLiked, false);
      expect(review.isSynced, true);
    });

    test('should create Review from JSON', () {
      final json = {
        'id': '123',
        'name': 'Jane Smith',
        'rating': 4,
        'date': '2025-12-02T10:00:00.000Z',
        'comment': 'Good work',
        'likes': 5,
        'isLiked': true,
        'mediaPaths': ['path1.jpg', 'path2.jpg'],
        'contractorId': '456',
      };

      final review = Review.fromJson(json);

      expect(review.id, '123');
      expect(review.name, 'Jane Smith');
      expect(review.rating, 4);
      expect(review.comment, 'Good work');
      expect(review.likes, 5);
      expect(review.isLiked, true);
      expect(review.mediaFiles.length, 2);
      expect(review.contractorId, '456');
    });

    test('should handle null values in JSON', () {
      final json = {
        'rating': 3,
        'date': '2025-12-02T10:00:00.000Z',
      };

      final review = Review.fromJson(json);

      expect(review.name, '');
      expect(review.rating, 3);
      expect(review.comment, '');
      expect(review.likes, 0);
      expect(review.isLiked, false);
      expect(review.mediaFiles, isEmpty);
    });

    test('should convert Review to JSON', () {
      final review = Review(
        id: '789',
        name: 'Test User',
        rating: 5,
        date: DateTime(2025, 12, 2, 10, 30),
        comment: 'Excellent!',
        likes: 15,
        isLiked: true,
        mediaFiles: ['image1.jpg'],
        contractorId: '999',
      );

      final json = review.toJson();

      expect(json['id'], '789');
      expect(json['name'], 'Test User');
      expect(json['rating'], 5);
      expect(json['comment'], 'Excellent!');
      expect(json['likes'], 15);
      expect(json['isLiked'], true);
      expect(json['mediaPaths'], ['image1.jpg']);
      expect(json['contractorId'], '999');
    });

    test('should handle mediaPaths as JSON string', () {
      final json = {
        'rating': 4,
        'date': '2025-12-02T10:00:00.000Z',
        'mediaPaths': '["file1.jpg", "file2.jpg"]',
      };

      final review = Review.fromJson(json);

      expect(review.mediaFiles.length, 2);
      expect(review.mediaFiles[0], 'file1.jpg');
      expect(review.mediaFiles[1], 'file2.jpg');
    });
  });
}
