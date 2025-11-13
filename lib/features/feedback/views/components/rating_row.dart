import 'package:flutter/material.dart';

class RatingRow extends StatelessWidget {
  final String label;
  final int rating;
  final Function(int) onRatingChange;

  const RatingRow({
    super.key,
    required this.label,
    required this.rating,
    required this.onRatingChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final star = index + 1;
            return GestureDetector(
              onTap: () => onRatingChange(star),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  star <= rating ? Icons.star : Icons.star_border,
                  size: 20,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
