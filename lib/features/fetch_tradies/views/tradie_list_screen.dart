import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../viewmodels/tradie_viewmodel.dart';
import '../../fetch_tradies/models/tradie_request.dart';
import '../../fetch_tradies/models/tradie_model.dart';

class TradieDetailScreen extends ConsumerStatefulWidget {
  final int jobId;
  const TradieDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<TradieDetailScreen> createState() => _TradieDetailScreenState();
}

class _TradieDetailScreenState extends ConsumerState<TradieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(tradieViewModelProvider.notifier)
          .fetchTradieDetailAndRecommendations(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tradieViewModelProvider);

    final job = state.jobs.firstWhere(
      (j) => j.id == widget.jobId,
      orElse: () => TradieRequest(
        id: widget.jobId,
        title: 'Job #${widget.jobId}',
        description: '',
        status: 'pending',
        jobType: 'standard',
      ),
    );

    final recommendations = ref.watch(
      tradieViewModelProvider.select(
        (s) => s.recommendations[widget.jobId] ?? [],
      ),
    );
    final loading = state.isLoadingRecommendations;
    final error = state.recommendationsError;

    return Scaffold(
      appBar: AppBar(
        title: Text('Job • ${job.title}', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            if (job.description.isNotEmpty)
              Text(job.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.spacing16),

            // Location & type chips
            Wrap(
              spacing: AppDimensions.spacing8,
              runSpacing: AppDimensions.spacing8,
              children: [
                Chip(
                  avatar: const Icon(
                    Icons.location_on,
                    size: AppDimensions.iconSmall,
                    color: AppColors.onSecondary,
                  ),
                  label: Text(job.location ?? 'No location'),
                  backgroundColor: AppColors.secondaryLight,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSecondary,
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.work,
                    size: AppDimensions.iconSmall,
                    color: AppColors.onSecondary,
                  ),
                  label: Text(job.jobType),
                  backgroundColor: AppColors.secondaryLight,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacing24),
            Text(
              'Recommended Tradies',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.tradieBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),

            loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Text(
                      error,
                      style: AppTextStyles.errorText,
                      textAlign: TextAlign.center,
                    ),
                  )
                : recommendations.isEmpty
                ? const Center(child: Text('No suitable tradies found.'))
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recommendations.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.spacing12),
                    itemBuilder: (context, index) {
                      final TradieModel t = recommendations[index];
                      return Card(
                        elevation: AppDimensions.elevationMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.tradieGreen,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          title: Text(
                            t.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            t.skills.map((s) => s.name).join(', '),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          trailing: Chip(
                            label: Text(
                              t.rating?.toStringAsFixed(1) ?? 'N/A',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Book ${t.name} — coming soon'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
