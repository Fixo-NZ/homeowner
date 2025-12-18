import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/viewmodels/auth_viewmodel.dart';
import '../../models/contractor.dart';
import '../../viewmodels/feedback_viewmodel.dart';
import 'rating_row.dart';

class RateServiceForm extends ConsumerStatefulWidget {
  final List<Contractor> contractors;
  final List<String> reviewedContractors;

  const RateServiceForm({
    super.key,
    required this.contractors,
    required this.reviewedContractors,
  });

  @override
  ConsumerState<RateServiceForm> createState() => _RateServiceFormState();
}

class _RateServiceFormState extends ConsumerState<RateServiceForm> {
  bool showReviewForm = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackViewModelProvider);
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    final selectedContractorData = state.selectedContractor != null
        ? state.contractors.firstWhere(
            (c) => c.id == state.selectedContractor,
          )
        : null;

    final availableContractors = state.contractors
        .where((c) => !state.reviewedContractors.contains(c.id))
        .toList();

    if (showReviewForm && selectedContractorData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => showReviewForm = false),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Change Contractor'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF090C9B),
            ),
          ),
          const SizedBox(height: 20),
          // User's submitted reviews (with delete action)
          Builder(builder: (context) {
            final authState = ref.watch(authViewModelProvider);
            final currentUserId = authState.user?.id?.toString();
            final myReviews = state.allReviews.where((r) => r.homeownerId == currentUserId).toList();

            if (myReviews.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Your Submitted Reviews',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: myReviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final review = myReviews[i];
                    final contractor = state.contractors.firstWhere(
                      (c) => c.id == review.contractorId,
                      orElse: () => Contractor(id: review.contractorId ?? '', name: 'Provider', specialty: '', avatar: review.name.isNotEmpty ? review.name[0] : '?', rating: 0.0, completedJobs: 0),
                    );

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF090C9B),
                            child: Text(contractor.avatar, style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(contractor.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('${review.rating} ★', style: const TextStyle(color: Color(0xFFFBBF24))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(review.comment, maxLines: 3, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      review.date.toLocal().toString().split(' ').first,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Review'),
                                            content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                            ],
                                          ),
                                        );
                                        if (confirm != true) return;

                                        // find index in global allReviews list
                                        final globalIndex = state.allReviews.indexWhere((r) => r.id != null ? r.id == review.id : r.date.toIso8601String() == review.date.toIso8601String());
                                        await viewModel.deleteReview(globalIndex);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted')));
                                        }
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
              ),
              border: Border.all(color: const Color(0xFFBFDBFE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF090C9B),
                  child: Text(
                    selectedContractorData.avatar,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedContractorData.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedContractorData.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${selectedContractorData.rating}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${selectedContractorData.completedJobs} jobs',
                            style: const TextStyle(
                              fontSize: 10,
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            onChanged: viewModel.setComment,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Rate Our Service',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          RatingRow(
            label: 'Overall Experience',
            rating: state.overallRating,
            onRatingChange: viewModel.setOverallRating,
          ),
          const SizedBox(height: 10),
          RatingRow(
            label: 'Quality of Service',
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
                  onChanged: (val) => viewModel.toggleUsername(val ?? false),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Show username', style: TextStyle(fontSize: 12)),
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
          // Bottom action row (full-width buttons like mobile)
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => viewModel.setActiveTab('reviews'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF090C9B)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF090C9B), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await viewModel.submitReview();
                      if (state.errorMessage != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage ?? 'Error'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF090C9B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('SUBMIT REVIEW', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service Provider',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const Text(
          'Choose who you want to review',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        if (availableContractors.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
              ),
              border: Border.all(color: const Color(0xFFBFDBFE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle,
                    size: 48, color: Color(0xFF15803D)),
                SizedBox(height: 12),
                Text(
                  'All Contractors Reviewed!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'You\'ve submitted reviews for all service providers.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
              ),
              border: Border.all(color: const Color(0xFFBFDBFE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: availableContractors.map((contractor) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                    child: Material(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        viewModel.selectContractor(contractor.id);
                        setState(() => showReviewForm = true);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF090C9B),
                              child: Text(
                                contractor.avatar,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    contractor.specialty,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Color(0xFFFBBF24),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${contractor.rating}',
                                        style:
                                            const TextStyle(fontSize: 10),
                                      ),
                                      const Text(
                                        ' • ',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      Text(
                                        '${contractor.completedJobs} jobs',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
