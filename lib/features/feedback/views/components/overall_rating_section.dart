import 'package:flutter/material.dart';
import 'star_rating.dart';

class OverallRatingSection extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;

  const OverallRatingSection({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 300;

          return isNarrow
              ? Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF090C9B),
                          ),
                        ),
                        StarRating(rating: averageRating, size: 16),
                        const SizedBox(height: 4),
                        Text(
                          '$totalReviews reviews',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [5, 4, 3].map((stars) {
                        final count = ratingCounts[stars] ?? 0;
                        final percentage =
                            totalReviews == 0 ? 0.0 : count / totalReviews;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$stars',
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                size: 10,
                                color: Color(0xFFFDC700),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percentage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDC700),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 12,
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF090C9B),
                          ),
                        ),
                        StarRating(rating: averageRating, size: 16),
                        const SizedBox(height: 4),
                        Text(
                          '$totalReviews reviews',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [5, 4, 3].map((stars) {
                          final count = ratingCounts[stars] ?? 0;
                          final percentage =
                              totalReviews == 0 ? 0.0 : count / totalReviews;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '$stars',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Color(0xFFFDC700),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: percentage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDC700),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 12,
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
