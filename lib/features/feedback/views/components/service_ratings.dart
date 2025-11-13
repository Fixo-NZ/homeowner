import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/review.dart';
import '../../models/contractor.dart';
import 'star_rating.dart';
import 'overall_rating_section.dart';

class ServiceRatings extends StatefulWidget {
  final List<Contractor> contractors;
  final List<Review> allReviews;
  final List<Review> filteredReviews;
  final String selectedFilter;
  final Map<int, int> ratingCounts;
  final double averageRating;
  final Function(String) onFilterChanged;
  final Function(int) onToggleLike;
  final Function(int) onDeleteReview;
  final Function(String) onContractorClick;

  const ServiceRatings({
    super.key,
    required this.contractors,
    required this.allReviews,
    required this.filteredReviews,
    required this.selectedFilter,
    required this.ratingCounts,
    required this.averageRating,
    required this.onFilterChanged,
    required this.onToggleLike,
    required this.onDeleteReview,
    required this.onContractorClick,
  });

  @override
  State<ServiceRatings> createState() => _ServiceRatingsState();
}

class _ServiceRatingsState extends State<ServiceRatings> {
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final days = difference.inDays;

    if (days < 30) return '${days}d ago';
    if (days < 365) return '${(days / 30).floor()}mo ago';
    return '${(days / 365).floor()}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OverallRatingSection(
          averageRating: widget.averageRating,
          totalReviews: widget.allReviews.length,
          ratingCounts: widget.ratingCounts,
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', '5 Star', '4 Star', '3 Star', '2 Star', '1 Star']
                .map((filter) {
              final count = filter == 'All'
                  ? widget.allReviews.length
                  : widget.ratingCounts[int.parse(filter.split(' ')[0])] ?? 0;
              final isSelected = widget.selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => widget.onFilterChanged(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFDCEFFF)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$filter ($count)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Recent Reviews',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...widget.filteredReviews.asMap().entries.map((entry) {
          final index = widget.allReviews.indexOf(entry.value);
          final review = entry.value;
          final isUserReview = review.name == 'mark_allen_dicoolver' ||
              review.name == 'Anonymous User';
          final contractor = review.contractorId != null
              ? widget.contractors.firstWhere(
                  (c) => c.id == review.contractorId,
                )
              : null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isUserReview
                          ? const Color(0xFF15803D)
                          : const Color(0xFF1D4ED8),
                      child: Text(
                        review.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  review.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 12,
                                color: Color(0xFF1D4ED8),
                              ),
                              if (isUserReview) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            formatDate(review.date),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 16),
                      itemBuilder: (context) => [
                        if (isUserReview)
                          PopupMenuItem(
                            child: const Text(
                              'Delete Review',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () => widget.onDeleteReview(index),
                          )
                        else
                          const PopupMenuItem(child: Text('Report Review')),
                        const PopupMenuItem(child: Text('Share Review')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StarRating(rating: review.rating.toDouble(), size: 14),
                if (contractor != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Review for: ',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () =>
                              widget.onContractorClick(contractor.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: const Color(0xFF090C9B),
                                  child: Text(
                                    contractor.avatar,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    contractor.name,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF090C9B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${contractor.specialty})',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (review.mediaFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.mediaFiles.length,
                      itemBuilder: (context, i) {
                        final file = review.mediaFiles[i];
                        final isVideo = file.toLowerCase().endsWith('.mp4') ||
                            file.toLowerCase().endsWith('.mov');
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: isVideo
                                ? Container(
                                    color: Colors.black87,
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  )
                                : Image.file(
                                    File(file),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => widget.onToggleLike(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: review.isLiked
                          ? const Color(0xFFDCEFFF)
                          : Colors.transparent,
                      border: Border.all(
                        color: review.isLiked
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFD1D5DB),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          review.isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          size: 12,
                          color: review.isLiked
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review.likes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: review.isLiked
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
