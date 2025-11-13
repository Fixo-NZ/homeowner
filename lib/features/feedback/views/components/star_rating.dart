import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: const Color(0xFFFDC700));
        } else if (index < rating) {
          return Icon(
            Icons.star_half,
            size: size,
            color: const Color(0xFFFDC700),
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: const Color(0xFFFDC700),
          );
        }
      }),
    );
  }
}
