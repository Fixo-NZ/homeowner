import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/feedback_viewmodel.dart';
import 'components/top_bar.dart';
import 'components/header_section.dart';
import 'components/tab_list.dart';
import 'components/service_ratings.dart';
import 'components/rate_service_form.dart';
import 'components/review_success_page.dart';
import 'contractor_review_screen.dart';

class ServiceReviewsScreen extends ConsumerWidget {
  const ServiceReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackViewModelProvider);
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: state.viewingContractor != null
          ? ContractorReviewScreen(contractor: state.viewingContractor!)
          : Column(
              children: [
                TopBar(
                  onBack: () => viewModel.setActiveTab('reviews'),
                  onHome: () => viewModel.setActiveTab('reviews'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HeaderSection(),
                        const SizedBox(height: 20),
                        TabList(
                          activeTab: state.activeTab,
                          onTabChange: viewModel.setActiveTab,
                        ),
                        const SizedBox(height: 20),
                        if (state.activeTab == 'reviews')
                          ServiceRatings(
                            contractors: state.contractors,
                            allReviews: state.allReviews,
                            filteredReviews: viewModel.filteredReviews,
                            selectedFilter: state.selectedFilter,
                            ratingCounts: viewModel.ratingCounts,
                            averageRating: viewModel.averageRating,
                            onFilterChanged: (filter) {
                              // Implement filter change
                            },
                            onToggleLike: viewModel.toggleLike,
                            onDeleteReview: viewModel.deleteReview,
                            onContractorClick: viewModel.handleContractorClick,
                          )
                        else if (state.isReviewSubmitted)
                          ReviewSuccessPage(
                            onSubmitAnother: viewModel.submitAnother,
                            onViewReviews: viewModel.viewAllReviews,
                          )
                        else
                          RateServiceForm(
                            contractors: state.contractors,
                            reviewedContractors: state.reviewedContractors,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
