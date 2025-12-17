import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeowner/features/job_posting/models/job_posting_models.dart';
import 'package:intl/intl.dart';
import '../../../features/job_posting/viewmodels/job_posting_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../models/job_applicant_models.dart';
import '../viewmodels/job_applicant_viewmodel.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadJobDetails();
    });
  }

  @override
  void didUpdateWidget(JobDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId) {
      _loadJobDetails();
    }
  }

  void _loadJobDetails() {
    ref.read(jobPostingViewModelProvider.notifier).clearSelectedJob();
    ref.read(jobPostingViewModelProvider.notifier).loadJobOfferDetails(widget.jobId);
  }

  void _handleEdit() {
    context.push('/jobs/${widget.jobId}/edit');
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text(
          'Are you sure you want to delete this job? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(jobPostingViewModelProvider.notifier).deleteJobOffer(widget.jobId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                if (context.mounted) {
                  context.go('/jobs');
                }
              } else if (context.mounted) {
                final error = ref.read(jobPostingViewModelProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete job: ${error ?? "Unknown error"}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobPostingViewModelProvider);
    final job = state.selectedJobDetail;

    if (job != null && job.id != widget.jobId && !state.isLoadingJobDetail) {
      Future.microtask(() {
        _loadJobDetails();
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/jobs'),
        ),
        title: const Text('Job Details'),
        centerTitle: true,
        actions: [
          if (job != null && job.id == widget.jobId)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _handleEdit();
                } else if (value == 'delete') {
                  _handleDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(JobPostingState state) {
    if (state.isLoadingJobDetail) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading job',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadJobDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final job = state.selectedJobDetail;
    if (job == null || job.id != widget.jobId) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading job details...'),
          ],
        ),
      );
    }

    return _buildJobContent(job);
  }

  Widget _buildJobContent(JobPostResponse job) {
    final photoUrls = job.allPhotoUrls;
    final categoryName = job.category?['name'] as String? ?? 'Uncategorized';
    final services = job.services ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(job.status ?? 'open'),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (job.status ?? 'open').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title and Category
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.category,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                categoryName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Job Information Section
          _buildSectionHeader('Job Information'),

          _buildInfoRow('Job Type', _formatJobType(job.jobType)),
          _buildInfoRow('Job Size', _formatJobSize(job.jobSize)),

          if (job.jobType.toLowerCase() == 'recurrent') ...[
            if (job.startDate != null)
              _buildInfoRow(
                'Start Date',
                DateFormat('MMMM d, yyyy').format(job.startDate!),
              ),
            if (job.endDate != null)
              _buildInfoRow(
                'End Date',
                DateFormat('MMMM d, yyyy').format(job.endDate!),
              ),
            if (job.frequency != null)
              _buildInfoRow('Frequency', _formatFrequency(job.frequency!)),
          ] else if (job.preferredDate != null)
            _buildInfoRow(
              'Preferred Date',
              DateFormat('MMMM d, yyyy').format(job.preferredDate!),
            ),

          const SizedBox(height: 24),

          // Description Section
          _buildSectionHeader('Description'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              job.description ?? 'No description provided',
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 24),

          // Address Section
          _buildSectionHeader('Location'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.address,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Services Section
          _buildSectionHeader('Services'),
          if (services.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((service) {
                return Chip(
                  label: Text(service['name'] ?? 'Unnamed Service'),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide.none,
                );
              }).toList(),
            )
          else
            const Text('No services selected'),

          const SizedBox(height: 24),

          // Photos Section
          if (photoUrls.isNotEmpty) ...[
            _buildSectionHeader('Photos'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photoUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageDialog(context, photoUrls[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(photoUrls[index]),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // *** Applicants Section Added Here ***
          const SizedBox(height: 24),

          if (job.status == 'open' || job.status == 'in_progress') ...[
            _buildSectionHeader('Applicants'),
            Consumer(
              builder: (context, ref, child) {
                final applicantState = ref.watch(jobApplicantViewModelProvider);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (applicantState.applicants == null && !applicantState.isLoading) {
                    ref.read(jobApplicantViewModelProvider.notifier).loadApplicants(job.id);
                  }
                });

                if (applicantState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (applicantState.error != null) {
                  return Text('Error: ${applicantState.error}');
                }

                final applicants = applicantState.applicants ?? [];

                if (applicants.isEmpty) {
                  return const Text('No applicants yet');
                }

                final acceptedApplicant = applicants.firstWhere(
                  (app) => app.isAccepted,
                );

                if (acceptedApplicant != null) {
                  return _buildAcceptedApplicantCard(acceptedApplicant, job.id);
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: applicants.where((app) => app.isPending).length,
                        itemBuilder: (context, index) {
                          final pendingApps = applicants.where((app) => app.isPending).toList();
                          final applicant = pendingApps[index];
                          return _buildApplicantCard(applicant, job.id);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${applicants.where((app) => app.isPending).length} pending applicant(s)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          if (job.status == 'open' || job.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Job'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(JobApplicant applicant, int jobId) {
    final tradie = applicant.tradie;
    final tradieName = tradie?['name'] ?? 'Tradie';
    final businessName = tradie?['business_name'] ?? '';
    final yearsExperience = tradie?['years_experience'] ?? 0;
    final hourlyRate = tradie?['hourly_rate'] ?? 0.0;

    return Consumer(
      builder: (context, ref, child) {
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tradieName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (businessName.isNotEmpty)
                            Text(
                              businessName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (applicant.message != null && applicant.message!.isNotEmpty)
                  Text(
                    '"${applicant.message!}"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Chip(
                      label: Text('${yearsExperience}y exp'),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    Chip(
                      label: Text('\$$hourlyRate/hr'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptApplicant(ref, jobId, applicant.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectApplicant(ref, jobId, applicant.id),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcceptedApplicantCard(JobApplicant applicant, int jobId) {
    final tradie = applicant.tradie;
    final tradieName = tradie?['name'] ?? 'Tradie';
    final businessName = tradie?['business_name'] ?? '';
    final yearsExperience = tradie?['years_experience'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
        color: Colors.green[50],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Accepted Tradie',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: const Icon(Icons.person, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tradieName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (businessName.isNotEmpty)
                        Text(
                          businessName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      Text(
                        '$yearsExperience years experience',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _completeJob(ref, jobId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark Job as Complete'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptApplicant(WidgetRef ref, int jobId, int applicationId) async {
    final success = await ref
        .read(jobApplicantViewModelProvider.notifier)
        .acceptApplicant(jobId, applicationId);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tradie accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectApplicant(WidgetRef ref, int jobId, int applicationId) async {
    final success = await ref
        .read(jobApplicantViewModelProvider.notifier)
        .rejectApplicant(jobId, applicationId);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application rejected'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeJob(WidgetRef ref, int jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Job'),
        content: const Text('Are you sure this job is completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(jobApplicantViewModelProvider.notifier)
          .completeJob(jobId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );

        if (context.mounted) {
          context.go('/jobs');
        }
      }
    }
  }

  // Helper methods for UI

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatJobType(String jobType) {
    switch (jobType.toLowerCase()) {
      case 'recurrent':
        return 'Recurrent';
      case 'single':
        return 'Single';
      default:
        return jobType;
    }
  }

  String _formatJobSize(String jobSize) {
    switch (jobSize.toLowerCase()) {
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      default:
        return jobSize;
    }
  }

  String _formatFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return frequency;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
