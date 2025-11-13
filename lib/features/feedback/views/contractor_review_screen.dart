import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/contractor.dart';
import '../viewmodels/feedback_viewmodel.dart';
import 'components/rating_row.dart';
import 'components/review_success_page.dart';

class ContractorReviewScreen extends ConsumerWidget {
  final Contractor contractor;

  const ContractorReviewScreen({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackViewModelProvider);
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => context.go('/dashboard'),
              ),
              const Flexible(
                child: Text(
                  'Review Contractor',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
        Expanded(
          child: state.isReviewSubmitted
              ? Center(
                  child: ReviewSuccessPage(
                    onSubmitAnother: viewModel.submitAnother,
                    onViewReviews: viewModel.viewAllReviews,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
                          ),
                          border:
                              Border.all(color: const Color(0xFFBFDBFE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: const Color(0xFF090C9B),
                              child: Text(
                                contractor.avatar,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contractor.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF090C9B),
                                    ),
                                  ),
                                  Text(
                                    contractor.specialty,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Color(0xFFFBBF24),
                                      ),
                                      Text(
                                        '${contractor.rating}',
                                        style:
                                            const TextStyle(fontSize: 12),
                                      ),
                                      const Text(
                                        ' • ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      Text(
                                        '${contractor.completedJobs} completed jobs',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your Review',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        maxLines: 4,
                        onChanged: viewModel.setComment,
                        decoration: InputDecoration(
                          hintText: 'Share your experience ...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${state.commentValue.length} characters',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Rate Their Service',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RatingRow(
                        label: 'Overall Experience',
                        rating: state.overallRating,
                        onRatingChange: viewModel.setOverallRating,
                      ),
                      const SizedBox(height: 10),
                      RatingRow(
                        label: 'Quality of Work',
                        rating: state.qualityRating,
                        onRatingChange: viewModel.setQualityRating,
                      ),
                      const SizedBox(height: 10),
                      RatingRow(
                        label: 'Response Time',
                        rating: state.responseRating,
                        onRatingChange: viewModel.setResponseRating,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: state.showUsername,
                              onChanged: (val) =>
                                  viewModel.toggleUsername(val ?? false),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Show username',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Display as: mark_allen_dicoolver',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: viewModel.backFromContractor,
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(color: Color(0xFF4B5563)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await viewModel.submitReview();
                              if (state.errorMessage != null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(state.errorMessage ?? 'Error'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF090C9B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('SUBMIT REVIEW'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
