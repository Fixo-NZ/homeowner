import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../viewmodels/tradie_viewmodel.dart';
import 'tradie_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradieListScreen extends ConsumerStatefulWidget {
  const TradieListScreen({super.key});

  @override
  ConsumerState<TradieListScreen> createState() => _TradieListScreenState();
}

class _TradieListScreenState extends ConsumerState<TradieListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tradieViewModelProvider.notifier).fetchJobs(status: 'active');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tradieViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs', style: AppTextStyles.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? Center(
          child: Text(
            state.error!,
            style: AppTextStyles.errorText,
            textAlign: TextAlign.center,
          ),
        )
            : ListView.separated(
          itemCount: state.jobs.length,
          separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacing12),
          itemBuilder: (context, index) {
            final job = state.jobs[index];
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
                title: Text(
                  job.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacing8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.category?.name ?? 'Uncategorized',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        job.location ?? 'No location',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey600,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TradieDetailScreen(jobId: job.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
