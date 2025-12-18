import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contractor.dart';
import '../viewmodels/feedback_viewmodel.dart';
import 'components/rating_row.dart';
import 'components/review_success_page.dart';

class ContractorReviewScreen extends ConsumerStatefulWidget {
  final Contractor contractor;

  const ContractorReviewScreen({
    super.key,
    required this.contractor,
  });

  @override
  ConsumerState<ContractorReviewScreen> createState() => _ContractorReviewScreenState();
}

class _ContractorReviewScreenState extends ConsumerState<ContractorReviewScreen> {
  int activeTab = 0; // 0: About, 1: Jobs Done, 2: Reviews

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackViewModelProvider);
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    final contractor = widget.contractor;

    final contractorReviews = state.allReviews.where((r) => r.contractorId == contractor.id).toList();

    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => context.go('/dashboard'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contractor.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
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
                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(16),
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
                              radius: 36,
                              backgroundColor: const Color(0xFF090C9B),
                              child: Text(
                                contractor.avatar,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contractor.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF090C9B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(contractor.specialty, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                                    const SizedBox(width: 6),
                                    Text('${contractor.rating} • ${contractor.completedJobs} jobs', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                  ])
                                ],
                              ),
                            ),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tabs
                      Row(
                        children: [
                          _TabButton(label: 'About Me', selected: activeTab == 0, onTap: () => setState(() => activeTab = 0)),
                          const SizedBox(width: 8),
                          _TabButton(label: 'Jobs Done', selected: activeTab == 1, onTap: () => setState(() => activeTab = 1)),
                          const SizedBox(width: 8),
                          _TabButton(label: 'Reviews', selected: activeTab == 2, onTap: () => setState(() => activeTab = 2)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tab content
                      if (activeTab == 0) ...[
                        const Text('Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('• Plumber'),
                        const Text('• 8+ Years Experience'),
                        const Text('• Auckland, New Zealand'),
                        const SizedBox(height: 12),
                        const Text('Certifications / Licenses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: const [
                          Chip(label: Text('Licensed Plumber')),
                          Chip(label: Text('Registered Plumber')),
                          Chip(label: Text('Water Safety Certification')),
                        ]),
                      ] else if (activeTab == 1) ...[
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2),
                          itemCount: 6,
                          itemBuilder: (context, i) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 48, color: Colors.white70))),
                            );
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text('${contractorReviews.length} Reviews', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        ...contractorReviews.asMap().entries.map((entry) {
                          final index = entry.key;
                          final review = entry.value;
                          final isUserReview = review.name == 'mark_allen_dicoolver' || review.name == 'Anonymous User';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  CircleAvatar(radius: 18, child: Text(review.name.isNotEmpty ? review.name[0].toUpperCase() : '?')),
                                  const SizedBox(width: 8),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(review.name, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Row(children: [Icon(Icons.star, size: 12, color: const Color(0xFFFDC700)), const SizedBox(width: 6), Text('${review.rating}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))])])),
                                  PopupMenuButton<int>(
                                    icon: const Icon(Icons.more_vert, size: 16),
                                    onSelected: (value) async {
                                      if (value == 0) {
                                        if (isUserReview) {
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

                                          // find index in global reviews list
                                          final globalIndex = state.allReviews.indexWhere((r) => r.id != null ? r.id == review.id : r.date.toIso8601String() == review.date.toIso8601String());
                                          await viewModel.deleteReview(globalIndex);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted')));
                                          }
                                        } else {
                                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review reported')));
                                        }
                                      } else if (value == 1) {
                                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not implemented')));
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem<int>(
                                        value: 0,
                                        child: Text(
                                          isUserReview ? 'Delete Review' : 'Report Review',
                                          style: isUserReview ? const TextStyle(color: Colors.red) : null,
                                        ),
                                      ),
                                      const PopupMenuItem<int>(value: 1, child: Text('Share')),
                                    ],
                                  )
                                ]),
                                const SizedBox(height: 8),
                                Text(review.comment),
                                if (review.mediaFiles.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: review.mediaFiles.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (ctx, i) {
                                        final dynamic fileObj = review.mediaFiles[i];
                                        String? path;
                                        if (fileObj is String) {
                                          path = fileObj;
                                        } else if (fileObj is XFile) {
                                          path = fileObj.path;
                                        }

                                        final isVideo = path != null && (path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov'));

                                        return Container(
                                          width: 100,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: (path == null || !File(path).existsSync())
                                                ? Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image, color: Colors.white70)))
                                                : isVideo
                                                    ? Container(color: Colors.black87, child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 32))
                                                    : Image.file(File(path), fit: BoxFit.cover),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(children: [
                                  GestureDetector(onTap: () { viewModel.toggleLike(state.allReviews.indexOf(review)); }, child: Row(children: [Icon(review.isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt, size: 16, color: review.isLiked ? const Color(0xFF2563EB) : const Color(0xFF6B7280)), const SizedBox(width: 6), Text('${review.likes}', style: const TextStyle(fontSize: 12))])),
                                  const SizedBox(width: 18),
                                  GestureDetector(onTap: () {}, child: Row(children: const [Icon(Icons.share, size: 16, color: Color(0xFF6B7280)), SizedBox(width: 6), Text('Share', style: TextStyle(fontSize: 12))])),
                                ])
                              ]),
                            ),
                          );
                        }).toList(),
                      ]
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFFBFDBFE) : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: selected ? const Color(0xFF0B2B8A) : const Color(0xFF6B7280), fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}
