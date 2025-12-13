import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../features/job_posting/viewmodels/job_posting_viewmodel.dart';
import '../models/job_posting_models.dart';
import '../../../core/navbar/custom_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  int _selectedIndex = 1; // Jobs tab is index 1
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    // Use a slight delay to ensure widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobsWithRetry();
    });
  }

  Future<void> _loadJobsWithRetry({int retryCount = 0}) async {
    if (retryCount >= 3) {
      print('Max retries reached for loading jobs');
      return;
    }
    
    try {
      if (mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }
      
      await ref.read(jobPostingViewModelProvider.notifier).loadJobOffers();
      
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
      
      // Check if there's still an error after loading
      final state = ref.read(jobPostingViewModelProvider);
      if (state.error != null && retryCount < 3) {
        print('Retrying job load (attempt ${retryCount + 1})...');
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
        _loadJobsWithRetry(retryCount: retryCount + 1);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
      print('Error loading jobs: $e');
    }
  }

  // ✔ Efficient navigation - no unnecessary rebuilds
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Already on this tab

    if (index == 0) {
      // Navigate to Dashboard/Home
      context.go('/dashboard');
      return;
    }

    if (index == 1) {
      // Already on Jobs, just refresh if needed
      _retryLoadJobs();
      return;
    }

    if (index == 2) {
      // Messages
      context.go('/messages');
      return;
    }

    if (index == 3) {
      // Profile
      context.go('/profile');
      return;
    }
  }

  void _onPlusButtonPressed() {
    context.go('/job');
  }

  void _viewJobDetails(int jobId) {
  // Clear any cached job detail before navigating
  ref.read(jobPostingViewModelProvider.notifier).clearSelectedJob();
  
  // Use go for proper navigation
  context.go('/jobs/$jobId');
}

  void _retryLoadJobs() {
    _loadJobsWithRetry();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobPostingViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Job Offers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isRefreshing ? Icons.hourglass_bottom : Icons.refresh,
              color: _isRefreshing ? AppColors.tradieBlue : null,
            ),
            onPressed: _isRefreshing ? null : _retryLoadJobs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildJobListBody(state),
          if (_isRefreshing && !state.isLoadingJobs)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onPlusButtonPressed: _onPlusButtonPressed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPlusButtonPressed,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildJobListBody(JobPostingState state) {
    // Show loading indicator for both loading states
    if (state.isLoadingJobs || _isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Error loading jobs',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: Text(
                state.error!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton(
              onPressed: _retryLoadJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
            if (state.error!.contains('timeout') || state.error!.contains('Connection timeout'))
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacing16),
                child: Text(
                  'Tip: Check your internet connection and try again',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final jobOffers = state.jobOffers ?? [];

    if (jobOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            Text(
              'No job offers yet',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: Text(
                'Tap the + button to create your first job post',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton(
              onPressed: _onPlusButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Job'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadJobsWithRetry();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: jobOffers.length,
        itemBuilder: (context, index) {
          final job = jobOffers[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(JobListResponse job) {
    final photoUrls = job.allPhotoUrls;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      child: InkWell(
        onTap: () => _viewJobDetails(job.id),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (job.category?['name'] != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimensions.spacing4,
                            ),
                            child: Text(
                              job.category!['name'],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing8,
                      vertical: AppDimensions.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacing12),
              
              if (job.description.isNotEmpty)
                Text(
                  job.description,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: AppDimensions.spacing12),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: AppDimensions.iconSmall,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Expanded(
                    child: Text(
                      job.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spacing8),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppDimensions.iconSmall,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    job.preferredDate != null
                        ? DateFormat('MMM d, yyyy').format(job.preferredDate!)
                        : 'No preferred date',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatJobType(job.jobType),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _getJobTypeColor(job.jobType),
                    ),
                  ),
                ],
              ),
              
              if (photoUrls.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        margin: EdgeInsets.only(
                          right: index < photoUrls.length - 1 
                            ? AppDimensions.spacing8 
                            : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          image: DecorationImage(
                            image: NetworkImage(photoUrls[index]),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image loading errors
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: AppDimensions.spacing8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.open;
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.tradieBlue;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'expired':
        return AppColors.onSurfaceVariant;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _formatJobType(String jobType) {
    switch (jobType.toLowerCase()) {
      case 'urgent':
        return 'Urgent';
      case 'recurrent':
        return 'Recurring';
      default:
        return 'Standard';
    }
  }

  Color _getJobTypeColor(String jobType) {
    switch (jobType.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'recurrent':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}