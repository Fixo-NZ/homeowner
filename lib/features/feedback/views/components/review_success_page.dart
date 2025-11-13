import 'package:flutter/material.dart';

class ReviewSuccessPage extends StatelessWidget {
  final VoidCallback onSubmitAnother;
  final VoidCallback onViewReviews;

  const ReviewSuccessPage({
    super.key,
    required this.onSubmitAnother,
    required this.onViewReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 40,
            color: Color(0xFF15803D),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Thank You!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF090C9B),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Your review has been submitted successfully',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onSubmitAnother,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF090C9B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('SUBMIT ANOTHER REVIEW'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onViewReviews,
          child: const Text(
            'VIEW ALL REVIEWS',
            style: TextStyle(color: Color(0xFF090C9B)),
          ),
        ),
      ],
    );
  }
}
